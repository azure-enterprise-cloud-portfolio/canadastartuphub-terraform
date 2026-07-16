# Infrastructure — Canada Startup Directory

Terraform for **canadastartupdirectory.ca**: the Route 53 hosted zone that
holds the site's DNS. Hosting is managed outside this repo (the previous AWS
Amplify setup was removed).

The domain is registered at **GoDaddy** (registrar only); DNS authority is
delegated to **Route 53**.

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
└── envs/
    └── prod/                    # Route 53 zone for canadastartupdirectory.ca
        ├── versions.tf
        ├── backend.tf
        ├── providers.tf
        ├── variables.tf
        ├── main.tf
        └── outputs.tf
```

---

## How deployment works

| Trigger | What runs |
|---|---|
| Pull request touching `infra/**` | fmt check → init → validate → **plan** |
| Push to `main` touching `infra/**` | same, plus **apply** |
| Manual (`workflow_dispatch`) | same as push |

The workflow assumes the IAM role in the `AWS_ROLE_ARN` secret via GitHub's
OIDC provider and runs Terraform in `infra/envs/prod`. Changes under
`bootstrap/**` never run through the pipeline — that stack is applied locally
on purpose, so the pipeline can't modify the role it authenticates with.

Required GitHub Actions secret (repo → Settings → Secrets and variables →
Actions):

| Secret | Purpose |
|---|---|
| `AWS_ROLE_ARN` | IAM role the workflow assumes (output of the bootstrap stack) |

---

## Pointing GoDaddy at Route 53

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

Delegation takes minutes to a few hours for a `.ca` domain. Verify with:

```powershell
nslookup -type=NS canadastartupdirectory.ca
```

DNS records for whatever hosts the site (A/AAAA/CNAME/ALIAS) should be added
to this zone — either as `aws_route53_record` resources in
`infra/envs/prod/main.tf` (preferred, keeps DNS in code) or manually in the
console.

---

## Day-to-day changes

Edit Terraform under `infra/`, open a PR, review the plan in the Actions run,
merge. The pipeline applies on merge. To run locally instead:

```powershell
cd infra\envs\prod
terraform init
terraform plan
```

---

## State & locking

Remote state lives in S3 (`canadastartupdirectory-tfstate`, key
`envs/prod/terraform.tfstate`) with Terraform's native S3 lockfile
(`use_lockfile = true`) — no DynamoDB table needed. The bootstrap stack keeps
its own key (`bootstrap/prod/terraform.tfstate`) in the same bucket. The
workflow creates the bucket (versioned, public access blocked) if it doesn't
exist.

---

## History note: Amplify removal

The stack previously managed an AWS Amplify app (Next.js SSR hosting) and its
domain association via `infra/modules/amplify-app` and
`infra/modules/amplify-domain`. Those were removed; the hosted zone was kept
and re-homed to the root module with a `moved` block in
`infra/envs/prod/main.tf` so its nameservers (and registrar delegation)
survived. The `AMPLIFY_GITHUB_TOKEN` secret is no longer used and can be
deleted from GitHub.
