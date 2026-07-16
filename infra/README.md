# Infrastructure — Canada Startup Hub

Terraform for the custom domain, TLS certificate, and AWS Amplify domain
association for **canadastartuphub.ca**.

The domain is registered at **GoDaddy** (registrar only); DNS authority is
delegated to **Route 53**. The web app is hosted on **AWS Amplify**. ACM
certificates are handled automatically by Amplify (`AMPLIFY_MANAGED`) unless an
environment opts into a bring-your-own certificate.

---

## Layout

```
infra/
├── modules/
│   └── amplify-domain/      # Reusable: Route 53 zone + ACM + Amplify domain
│       ├── versions.tf
│       ├── variables.tf
│       ├── main.tf
│       └── outputs.tf
└── envs/
    └── dev/                 # Dev environment (owns the shared hosted zone)
        ├── versions.tf
        ├── backend.tf
        ├── providers.tf
        ├── variables.tf
        ├── main.tf
        ├── outputs.tf
        └── terraform.tfvars
```

---

## Prerequisites

- Terraform >= 1.5
- AWS provider >= 5.82.0 (the `certificate_settings` block requires it)
- AWS CLI configured (`aws configure` or an SSO profile)
- Domain registered at GoDaddy (registrar only — DNS is delegated to Route 53)
- An existing Amplify app with a connected branch that has deployed at least once
- Remote state backend (S3 bucket + DynamoDB lock table) — bootstrapped in
  Step 1 below if it doesn't exist yet

---

## The `amplify-domain` module

Creates the Route 53 hosted zone (optional), optionally a custom ACM
certificate, and the Amplify domain association mapping branches to subdomains.

### Inputs

| Variable | Type | Default | Description |
|---|---|---|---|
| `domain_name` | string | — | Root domain, e.g. `canadastartuphub.ca` |
| `amplify_app_id` | string | — | Existing Amplify app ID |
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

## Environments

### dev

Owns the shared hosted zone (`create_hosted_zone = true`) and serves the app at
**dev.canadastartuphub.ca**, mapped to the `dev` Amplify branch.

Set your app ID before applying, in `envs/dev/terraform.tfvars`:

```hcl
amplify_app_id = "dXXXXXXXXXXXXX"
amplify_branch = "dev"
```

> There is only **one** hosted zone for the domain across all environments.
> Exactly one environment should create it; every other environment sets
> `create_hosted_zone = false` and passes `hosted_zone_id`.

---

## Deploying (dev) — end to end

Goal: `dev.canadastartuphub.ca` served by Amplify over HTTPS, with Route 53
authoritative for DNS, GoDaddy remaining only the registrar, and ACM handled
automatically by Amplify.

DNS delegation is a manual GoDaddy step in the middle, so this runs in phases.
Applying everything at once will hang on certificate verification, because ACM
cannot validate until Route 53 is authoritative for the domain.

### Step 1 — Bootstrap the state backend (skip if it already exists)

`terraform init` fails if the S3 bucket / DynamoDB lock table in `backend.tf`
don't exist. Create them once. `ca-central-1` requires the `LocationConstraint`:

```powershell
aws s3api create-bucket --bucket canadastartuphub-tfstate --region ca-central-1 --create-bucket-configuration LocationConstraint=ca-central-1
aws s3api put-bucket-versioning --bucket canadastartuphub-tfstate --versioning-configuration Status=Enabled
aws dynamodb create-table --table-name canadastartuphub-tflock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region ca-central-1
```

### Step 2 — Confirm the Amplify app and branch exist

The domain association maps to a **branch**, so the branch must exist and have
at least one successful build. In the Amplify console, verify:

- The app is connected to the repo.
- A branch named `dev` exists and shows a deployed state.
- Copy the **App ID** (looks like `dxxxxxxxxxxxxx`, top of the app page).

Terraform maps the domain to the branch; it does not create the branch. If
there's no `dev` branch yet, connect it in Amplify first.

### Step 3 — Set your App ID

In `envs/dev/terraform.tfvars`:

```hcl
amplify_app_id = "dXXXXXXXXXXXXX"
amplify_branch = "dev"
```

### Step 4 — Phase 1: create the hosted zone, get the nameservers

```powershell
cd infra\envs\dev
terraform init
terraform apply -target="module.amplify_domain.aws_route53_zone.this"
```

Copy the four values from the `route53_nameservers` output (they look like
`ns-123.awsdns-45.com`).

### Step 5 — Point GoDaddy at Route 53

In GoDaddy: **My Products → Domain → Manage DNS → Nameservers → Change →
"I'll use my own nameservers"**, paste all four Route 53 values, and save.

> Switching nameservers makes Route 53 authoritative and abandons any DNS
> records currently at GoDaddy (email/MX, verification records, etc.). For a
> freshly registered domain there's usually nothing to migrate, but if you set
> up email on it, recreate those records in the Route 53 zone afterward.

### Step 6 — Verify delegation propagated

Repeat until this returns the **AWS** nameservers, not GoDaddy's. For a `.ca`
(CIRA) domain this is often minutes but can take a few hours:

```powershell
nslookup -type=NS canadastartuphub.ca
```

Do not proceed until it has flipped — this is the single most common cause of a
stuck apply.

### Step 7 — Phase 2: apply everything

```powershell
terraform apply
```

Amplify requests the ACM cert, writes validation + routing records into Route
53, and provisions HTTPS. The domain association moves through
`PENDING_VERIFICATION → PENDING_DEPLOYMENT → AVAILABLE`. This can take 10–30
minutes; `wait_for_verification = true` blocks the apply until it settles.

### Step 8 — Verify the site is live

```powershell
nslookup dev.canadastartuphub.ca
curl.exe -I https://dev.canadastartuphub.ca
```

Expect an HTTP `200`/`301` and a valid TLS handshake. In the browser,
`https://dev.canadastartuphub.ca` should load with a valid padlock, and the
Amplify console should show the domain as **Available**.

---

## Adding a prod environment

Copy `envs/dev` to `envs/prod` and change:

```hcl
# envs/prod/main.tf
module "amplify_domain" {
  # ...
  create_hosted_zone = false
  hosted_zone_id     = "<zone id from dev output>"
  amplify_branch     = "main"
  subdomains         = ["", "www"]   # apex + www
}
```

Give prod its own state key in `backend.tf`
(`key = "envs/prod/terraform.tfstate"`). Since prod reuses the existing zone,
its apply has no GoDaddy step — a single `terraform apply` is enough.

---

## Troubleshooting

- **Domain association stuck in verification** — delegation isn't live yet.
  Re-run the `nslookup` check; only run the full apply once it returns AWS
  nameservers.
- **`certificate_settings` drift on every plan** — AWS provider older than
  5.57.0. Upgrade to >= 5.82.0.
- **Custom cert validation hangs** — the ACM cert must be in `us-east-1`; the
  module already places it there via the `us_east_1` provider alias. Confirm the
  alias is wired in the env's `providers` block.

---

## State & locking

Remote state lives in S3 with a DynamoDB lock table (see `backend.tf`). On
Terraform 1.10+ you can switch to native S3 locking (`use_lockfile = true`) and
drop the DynamoDB table, but the current config keeps the DynamoDB lock to stay
consistent with the existing setup.
