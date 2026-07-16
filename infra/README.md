# Infrastructure — Canada Startup Hub

Terraform for **canadastartuphub.ca**: the AWS Amplify app that hosts the
Next.js site (SSR), the Route 53 hosted zone, the TLS certificate, and the
Amplify domain association.

The domain is registered at **GoDaddy** (registrar only); DNS authority is
delegated to **Route 53**. ACM certificates are handled automatically by
Amplify (`AMPLIFY_MANAGED`) unless an environment opts into a
bring-your-own certificate.

Deployment is automated: GitHub Actions
(`.github/workflows/terraform.yml`) plans on pull requests and applies on
pushes to `main`, authenticating to AWS via an **OIDC role** — no long-lived
access keys. The role itself is created by the separate
[`bootstrap/`](../bootstrap/README.md) stack.

---

## Layout

```
bootstrap/                       # OIDC provider + CI role (applied once, locally)
infra/
├── modules/
│   ├── amplify-app/             # Amplify app + service role + production branch
│   └── amplify-domain/          # Route 53 zone + ACM + Amplify domain association
└── envs/
    └── prod/                    # canadastartuphub.ca (apex + www) on branch main
        ├── versions.tf
        ├── backend.tf
        ├── providers.tf
        ├── variables.tf
        ├── main.tf
        ├── outputs.tf
        └── terraform.tfvars
```

---

## How deployment works

| Trigger | What runs |
|---|---|
| Pull request touching `infra/**` | fmt check → init → validate → **plan** |
| Push to `main` touching `infra/**` | same, plus **apply** |
| Manual (`workflow_dispatch`) | same as push |

The workflow assumes the IAM role in the `AWS_ROLE_ARN` secret via GitHub's
OIDC provider, creates the S3 state bucket if it doesn't exist yet, and runs
Terraform in `infra/envs/prod`. Changes under `bootstrap/**` never run through
the pipeline — that stack is applied locally on purpose, so the pipeline can't
modify the role it authenticates with.

Required GitHub Actions secrets (repo → Settings → Secrets and variables →
Actions):

| Secret | Purpose |
|---|---|
| `AWS_ROLE_ARN` | IAM role the workflow assumes (output of the bootstrap stack) |
| `AMPLIFY_GITHUB_TOKEN` | GitHub token Amplify uses once to install its webhook on the app repo |

---

## Steps to follow (fresh setup, end to end)

Goal: `canadastartuphub.ca` and `www.canadastartuphub.ca` served by Amplify
over HTTPS, deployed entirely through the pipeline.

### Step 1 — Bootstrap the CI role (once, locally)

The pipeline can't create the role it needs to log in, so this first apply
runs on your machine with your own AWS credentials:

```powershell
cd bootstrap\envs\prod
terraform init
terraform apply
```

Copy the `github_actions_role_arn` output and save it as the **`AWS_ROLE_ARN`**
secret in GitHub. Details and troubleshooting: [`bootstrap/README.md`](../bootstrap/README.md).

### Step 2 — Create the Amplify GitHub token

Amplify needs a GitHub token once, to install its webhook on the app repo
(`canadastartuphub`). Create a fine-grained personal access token with
read/write **Webhooks** and read **Contents** on that repo (a classic token
with `repo` scope also works), and save it as the **`AMPLIFY_GITHUB_TOKEN`**
secret.

### Step 3 — Push to `main`

Commit and push (or merge a PR). The workflow assumes the OIDC role, creates
the `canadastartupdirectory-tfstate` bucket if it's missing, and applies. This
creates the Amplify app, the production branch, the Route 53 hosted zone, and
the domain association. The apply does **not** wait for certificate
verification (`wait_for_verification = false`) — that completes on its own
after Step 4.

### Step 4 — Point GoDaddy at Route 53

Get the four nameservers from the `route53_nameservers` output — either from
the apply log in the Actions run, or locally:

```powershell
cd infra\envs\prod
terraform init
terraform output route53_nameservers
```

In GoDaddy: **My Products → Domain → Manage DNS → Nameservers → Change →
"I'll use my own nameservers"**, paste all four values, save.

> Switching nameservers makes Route 53 authoritative and abandons any DNS
> records currently at GoDaddy (email/MX, verification records, etc.). If you
> set up email on the domain, recreate those records in the Route 53 zone.

### Step 5 — Wait for delegation

Repeat until this returns the **AWS** nameservers, not GoDaddy's — minutes to
a few hours for a `.ca` domain:

```powershell
nslookup -type=NS canadastartuphub.ca
```

Once delegation is live, Amplify validates the certificate and the domain
association moves `PENDING_VERIFICATION → PENDING_DEPLOYMENT → AVAILABLE`
(10–30 minutes) with no further Terraform runs needed.

### Step 6 — Verify the site

```powershell
nslookup canadastartuphub.ca
curl.exe -I https://canadastartuphub.ca
curl.exe -I https://www.canadastartuphub.ca
```

Expect `200`/`301` with a valid TLS handshake, and the domain showing
**Available** in the Amplify console.

### Step 7 — Clean up old credentials (if migrating from access keys)

After the first green OIDC-authenticated run, delete the `AWS_ACCESS_KEY_ID`
and `AWS_SECRET_ACCESS_KEY` secrets from GitHub and deactivate that IAM user's
access keys in AWS.

### Day-to-day changes

Edit Terraform under `infra/`, open a PR, review the plan in the Actions run,
merge. The pipeline applies on merge. To run locally instead:

```powershell
cd infra\envs\prod
$env:TF_VAR_github_token = "<AMPLIFY_GITHUB_TOKEN value>"
terraform init
terraform plan
```

---

## The `amplify-app` module

Creates the Amplify app (platform `WEB_COMPUTE` for Next.js SSR), an IAM
service role with `AdministratorAccess-Amplify`, and the production branch
with auto-build enabled. Build config lives in `amplify.yml` in the app repo;
Amplify auto-detects Next.js when it's absent.

| Variable | Type | Default | Description |
|---|---|---|---|
| `app_name` | string | — | Amplify app name |
| `repository_url` | string | — | App repo URL, e.g. `https://github.com/owner/repo` |
| `github_token` | string | — | Token for the Amplify webhook; pass via `TF_VAR_github_token` |
| `branch_name` | string | `main` | Branch that deploys to production |
| `environment_variables` | map(string) | `{}` | App-level build-time env vars |
| `tags` | map(string) | `{}` | Tags applied to created resources |

Outputs: `app_id`, `branch_name`, `default_domain` (test at
`https://main.<default_domain>` before DNS cutover).

---

## The `amplify-domain` module

Creates the Route 53 hosted zone (optional), optionally a custom ACM
certificate, and the Amplify domain association mapping branches to subdomains.

### Inputs

| Variable | Type | Default | Description |
|---|---|---|---|
| `domain_name` | string | — | Root domain, e.g. `canadastartuphub.ca` |
| `amplify_app_id` | string | — | Amplify app ID |
| `amplify_branch` | string | — | Amplify branch to map the domain to |
| `subdomains` | list(string) | `["", "www"]` | Prefixes to map; `""` is the apex |
| `create_hosted_zone` | bool | `true` | Create the zone, or reuse an existing one |
| `hosted_zone_id` | string | `null` | Required when `create_hosted_zone = false` |
| `certificate_type` | string | `AMPLIFY_MANAGED` | `AMPLIFY_MANAGED` or `CUSTOM` |
| `tags` | map(string) | `{}` | Tags applied to created resources |

### Outputs

| Output | Description |
|---|---|
| `hosted_zone_id` | Zone ID (created or passed in) |
| `name_servers` | The 4 nameservers to set at GoDaddy (null if zone not created) |
| `certificate_verification_dns_record` | Amplify domain verification record |

### Certificate modes

- **`AMPLIFY_MANAGED`** (default) — Amplify requests the ACM cert, writes the
  validation records into the zone, and auto-renews it. Nothing else to manage.
- **`CUSTOM`** — the module requests an ACM cert in **us-east-1** (required
  because Amplify serves via CloudFront), validates it via Route 53, and passes
  the ARN to Amplify. Use only for a specific compliance or TLS-config reason.

The module requires a `us_east_1` provider alias regardless of mode; it's only
used when `certificate_type = "CUSTOM"`.

---

## Adding another environment

Copy `envs/prod` to `envs/<name>` and change:

```hcl
# envs/<name>/main.tf
module "amplify_domain" {
  # ...
  create_hosted_zone = false
  hosted_zone_id     = "<zone id from prod output>"
  amplify_branch     = "<branch>"
  subdomains         = ["<name>"] # e.g. dev.canadastartuphub.ca
}
```

Give it its own state key in `backend.tf`
(`key = "envs/<name>/terraform.tfstate"`).

> There is only **one** hosted zone for the domain across all environments.
> Exactly one environment (currently prod) creates it; every other environment
> sets `create_hosted_zone = false` and passes `hosted_zone_id`.

---

## Troubleshooting

- **Workflow fails at "Configure AWS credentials"** — `AWS_ROLE_ARN` secret
  missing/wrong, or the bootstrap stack hasn't been applied. Fork PRs also
  fail here by design: GitHub withholds OIDC tokens from forks.
- **Domain association stuck in `PENDING_VERIFICATION`** — delegation isn't
  live yet. Re-run `nslookup -type=NS canadastartuphub.ca`; it must return AWS
  nameservers.
- **`certificate_settings` drift on every plan** — AWS provider older than
  5.82.0. Upgrade.
- **Custom cert validation hangs** — the ACM cert must be in `us-east-1`; the
  module already places it there via the `us_east_1` provider alias. Confirm
  the alias is wired in the env's `providers` block.

---

## State & locking

Remote state lives in S3 (`canadastartupdirectory-tfstate`, key
`envs/prod/terraform.tfstate`) with Terraform's native S3 lockfile
(`use_lockfile = true`) — no DynamoDB table needed. The bootstrap stack keeps
its own key (`bootstrap/prod/terraform.tfstate`) in the same bucket. The
workflow creates the bucket (versioned, public access blocked) if it doesn't
exist.
