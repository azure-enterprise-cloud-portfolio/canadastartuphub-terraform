# Terraform — Amazon SES for canadatechintelligence.ca

This directory holds the project's AWS infrastructure. Today that is Amazon
SES for the site's email; the bootstrap roots (state bucket, CI identity and
its permissions) are meant to carry future services too. All of it runs in
**ca-central-1**.

## Deployment model — read first

| Root | Applied by | How |
|---|---|---|
| `bootstrap/backend` | **the account owner only** | local CLI, own short-lived AWS credentials; see [Bootstrap](#bootstrap) |
| `bootstrap/github-oidc` | **the account owner only** | local CLI, own short-lived AWS credentials; see [Bootstrap](#bootstrap) |
| `environments/dev` | **GitHub Actions only**, after bootstrap | `terraform-dev.yml` on push to `develop` |
| `environments/prod` | **GitHub Actions only**, after bootstrap | `terraform-prod.yml` on push to `main`, after `production` approval |

Rules:

- **An AI assistant (Claude or any other) never runs `terraform apply` or
  `terraform destroy`**, in any root, bootstrap included. Nor does it run
  `terraform import`, `terraform state rm/mv/push`, or any AWS CLI command
  that creates, updates or deletes a resource. It may run `terraform fmt`,
  `validate`, `plan` and `show`, `bash terraform/scripts/validate.sh`, and
  read-only AWS inspection (`describe`/`get`/`list`,
  `aws sts get-caller-identity`).
- **DEV and PROD are never applied from a workstation**, by anyone. They
  deploy only through their workflows.
- **Bootstrap is the only local apply**, and only the account owner runs it.
  It is rare: once to set up, and again when the bucket, the CI roles or a
  service's CI permissions change (see [Adding a service](#adding-a-service)).
- **No permanent AWS access keys.** The owner's local runs use short-lived
  credentials (`aws login` or IAM Identity Center). CI authenticates with
  GitHub OIDC only. Never create an IAM user or access key for either.

| Change | Path |
|---|---|
| PR to `develop`/`main` | `terraform-pr.yml`: fmt + validate + plan. **No apply.** |
| merge to `develop` | `terraform-dev.yml`: DEV apply |
| merge to `main` | `terraform-prod.yml`: PROD plan → `production` approval → apply |
| bootstrap (rare) | the account owner, locally — [Bootstrap](#bootstrap) |

```
terraform/
├── bootstrap/
│   ├── backend/        # central S3 state bucket                          (owner, local)
│   └── github-oidc/    # CI identity: OIDC provider, plan/dev/prod roles, trust,
│                       # state access, service policies, permissions boundary (owner, local)
├── modules/
│   └── ses/            # reusable SES identity/DKIM/MAIL FROM/config set/policy
├── environments/
│   ├── dev/            # DEV  (terraform-dev.yml)
│   └── prod/           # PROD (terraform-prod.yml)
└── scripts/
    └── validate.sh     # fmt + validate every root, no AWS access needed
```

## Independent states — values cross by hand

Four roots, four state files, one bucket. **No root reads another root's state.**
There is no `terraform_remote_state` and no output discovery, and no dependency
runs between roots. Bootstrap never depends on DEV or PROD, and DEV/PROD never
create the bucket, the OIDC provider or the CI roles. The few values that cross
a boundary are entered by hand; see [Manual values](#manual-values).

| Root | State key (central bucket) | Applied by |
|---|---|---|
| `bootstrap/backend` | `bootstrap/backend/terraform.tfstate` | account owner, local CLI |
| `bootstrap/github-oidc` | `bootstrap/github-oidc/terraform.tfstate` | account owner, local CLI |
| `environments/dev` | `dev/terraform.tfstate` | `terraform-dev.yml` on push to `develop` |
| `environments/prod` | `prod/terraform.tfstate` | `terraform-prod.yml` on push to `main`, after approval |

**State bucket:** versioning on, with old versions kept 90 days as the rollback
window. It uses SSE-S3 encryption, blocks all public access and enforces
BucketOwnerEnforced ownership. The bucket policy denies non-HTTPS requests and
TLS below 1.2, and denies `s3:DeleteBucket` to everyone. `prevent_destroy` and
`force_destroy = false` add a second guard. Locking is S3-native
(`use_lockfile = true`, Terraform ≥ 1.10), so there is no DynamoDB table.

**The bucket's own state.** `bootstrap/backend` creates the bucket its state
lives in, so its first run uses local state and then migrates it into the new
bucket. The exact commands are in [Bootstrap](#bootstrap). Every later run uses
the S3 backend directly.

## DNS: what Terraform may and may not touch

The `canadatechintelligence.ca` hosted zone already exists. GoDaddy is only the
registrar. Terraform reads the zone with a **data source**. It never creates,
imports or owns the zone, and the SES module never modifies an existing
record.

Existing records that stay untouched (checked 2026-09-28 against public DNS):
- apex `MX 0 canadatechintelligence-ca.mail.protection.outlook.com` (Microsoft 365 mailbox)
- apex `TXT "v=spf1 include:secureserver.net -all"` and `TXT "MS=ms13492863"`

Route 53 keeps every TXT value at one name as a single record set. Adding SES
to the apex SPF would therefore mean taking over the apex TXT record. So SES
uses a **custom MAIL FROM subdomain** that carries its own SPF, and Easy DKIM
verifies the domain. No `_amazonses` TXT record is needed.

New records only (PROD / DEV):

| Name | Type | Value |
|---|---|---|
| `<token1..3>._domainkey.canadatechintelligence.ca` | CNAME | `<token>.dkim.amazonses.com` |
| `bounce.canadatechintelligence.ca` | MX | `10 feedback-smtp.ca-central-1.amazonses.com` |
| `bounce.canadatechintelligence.ca` | TXT | `"v=spf1 include:amazonses.com -all"` |
| `<token1..3>._domainkey.dev.canadatechintelligence.ca` | CNAME | `<token>.dkim.amazonses.com` |
| `bounce.dev.canadatechintelligence.ca` | MX | `10 feedback-smtp.ca-central-1.amazonses.com` |
| `bounce.dev.canadatechintelligence.ca` | TXT | `"v=spf1 include:amazonses.com -all"` |

Guards:
- Every record sets `allow_overwrite = false`, so a name collision fails
  instead of taking over the record.
- The deploy roles may change records **only in this hosted zone** (not
  per record: any name in the zone is allowed, by design).
- Their permissions boundary refuses any change batch that touches a
  **protected name**, whatever the record type: the apex
  (`canadatechintelligence.ca`: Microsoft 365 MX, SPF and `MS=` verification
  TXT, and the site's own apex records), `autodiscover`,
  `selector1._domainkey`, `selector2._domainkey` and `_dmarc`. The list is the
  `protected_dns_labels` variable of `bootstrap/github-oidc`; extend it, never
  shorten it. The zone itself can't be deleted by any CI role.

## SES

| | PROD | DEV |
|---|---|---|
| Domain identity | `canadatechintelligence.ca` | `dev.canadatechintelligence.ca` |
| Sender (From)   | `contact@canadatechintelligence.ca` | `noreply@dev.canadatechintelligence.ca` |
| Destination     | `contact@canadatechintelligence.ca` | `contact@canadatechintelligence.ca` |
| MAIL FROM       | `bounce.canadatechintelligence.ca` | `bounce.dev.canadatechintelligence.ca` |
| Config set      | `canadastartuphub-prod` | `canadastartuphub-dev` |
| Send policy     | `canadastartuphub-ses-send-prod` | `canadastartuphub-ses-send-dev` |

DEV uses a subdomain because an SES domain identity is unique per account and
region, so DEV and PROD can't both verify the apex.

Each configuration set requires TLS, publishes reputation metrics and
suppresses addresses that bounce or complain. The send policy is created
**unattached**, because nothing in the app sends mail yet. It allows
`ses:SendEmail`/`SendRawEmail` only from the configured sender and only to
`contact@canadatechintelligence.ca`. Attach it to the role that eventually
sends mail, never to an IAM user with access keys.

## IAM / OIDC

Everything here is one root, `bootstrap/github-oidc`, applied locally by the
account owner. Its files, by responsibility:

| File | Holds |
|---|---|
| `oidc.tf` | the GitHub OIDC provider |
| `roles.tf` | the plan, dev and prod roles and their OIDC trust |
| `policies.tf` | what each role may do: (1) Terraform state, (2) deployment, (3) plan read, (4) the permissions boundary |
| `data.tf`, `locals.tf` | account/partition, provider lookup, the hosted-zone lookup, derived names, ARNs and protected DNS names |

**Roles and trust**

| Role | Trusted OIDC `sub` | Used by |
|---|---|---|
| `canadastartuphub-terraform-plan` | `…:pull_request`, `…:ref:refs/heads/main` | `terraform-pr.yml`; the plan job of `terraform-prod.yml` |
| `canadastartuphub-terraform-dev` | `…:environment:dev` | `terraform-dev.yml` |
| `canadastartuphub-terraform-prod` | `…:environment:production` | the apply job of `terraform-prod.yml` |

`…` is `repo:azure-enterprise-cloud-portfolio/canadastartuphub`. The OIDC
provider `token.actions.githubusercontent.com` is created here by default; set
`create_github_oidc_provider = false` if the account already has one, and it
is looked up instead.

**Permissions (`policies.tf`)**

| Layer | Plan role | Dev role | Prod role |
|---|---|---|---|
| 1. State (inline `terraform-state`) | `GetObject` on `dev/*` and `prod/*` | Get/Put/Delete on `dev/*` | Get/Put/Delete on `prod/*` |
| 2. Deployment (managed `canadastartuphub-ci-deploy-<env>`) | — | see below | same as dev |
| 3. Plan read (managed `canadastartuphub-ci-plan-read`) | read-only view of the same services | — | — |
| 4. Boundary `canadastartuphub-ci-boundary` | ✓ | ✓ | ✓ |

All three roles also have `s3:ListBucket` on the state bucket. It only returns
key names, and it isn't prefix-limited because the S3 backend lists its
workspace prefix during `init`.

**Deployment policy (DEV and PROD, identical apart from the environment):**

| Grant | Actions | Resource |
|---|---|---|
| Application services | `apigateway:*`, `dynamodb:*`, `events:*`, `lambda:*`, `logs:*`, `sns:*`, `sqs:*` | `*` |
| SES management | `ses:*` (sending denied by the boundary) | `*` |
| Route 53 records | `ChangeResourceRecordSets`, `GetHostedZone`, `ListResourceRecordSets`, `ListTagsForResource` | the CTI hosted zone only |
| Route 53 change status | `GetChange` | `change/*` |
| Route 53 zone lookup | `ListHostedZones`, `ListHostedZonesByName` | `*` (no resource-level support) |
| SES send policy | `iam:Create/Delete/Get Policy`, `…PolicyVersion`, `Tag/Untag/ListPolicyTags` | `policy/canadastartuphub/ses/<env>/*` only |

`"Resource": "*"` is used where the grant is service-level by design, and for
the account-level actions of those services that accept nothing else (for
example `lambda:ListFunctions`, `logs:DescribeLogGroups`, `sqs:ListQueues`,
`dynamodb:ListTables`, `ses:GetAccount`, `route53:ListHostedZones`).

Deliberately **absent** until a service needs it, then added narrowly:
`iam:PassRole`, Secrets Manager and SSM. Until `iam:PassRole` exists, anything
that passes a role to a service fails (creating a Lambda function, API Gateway
CloudWatch logging, a role-based EventBridge target). There is no `iam:*`,
`AdministratorAccess` or `PowerUserAccess`.

**The permissions boundary grants nothing**: a role can do only what both its
own policies and the boundary allow. Its one Allow is a ceiling; its Deny
statements hold even if a policy above is ever widened by mistake:

- no IAM users, access keys or passwords;
- no changes to the CI roles, their trust, their policies, the boundary (all
  under `/canadastartuphub/ci/`) or the OIDC provider — no self-modification,
  no privilege escalation;
- no SES sending (`ses:Send*`);
- no change to a protected DNS name (see [DNS](#dns-what-terraform-may-and-may-not-touch))
  and no hosted-zone deletion;
- no change to the state bucket's protections, no access to `bootstrap/*`, no
  deleting state history (`DeleteObjectVersion`);
- nothing outside `ca-central-1` except global services (IAM, STS, Route 53,
  CloudFront, Support);
- no Organizations, account or billing administration (`organizations`,
  `account`, `aws-portal`, `billing`, `budgets`, `ce`, `cur`, `freetier`,
  `invoicing`, `payments`, `purchase-orders`, `tax`).

A future service that needs another region (for example ACM in `us-east-1`
for CloudFront) must be added to the region exemptions deliberately.

> **DEV and PROD are not isolated from each other at the resource level.**
> Both deploy roles live in one AWS account and hold the same service-level
> permissions, so the DEV role can change or delete a PROD Lambda, table,
> queue, topic, log group, API or SES identity (and vice versa), and both can
> change any unprotected record in the zone. What *is* isolated is Terraform
> **state**: DEV reads and writes only `dev/*`, PROD only `prod/*`, and
> neither can touch the other's state or `bootstrap/*`. Keep resource names
> environment-prefixed, and if resource-level isolation is ever needed, the
> clean fix is separate DEV and PROD AWS accounts. This trade-off was
> accepted on 2026-09-28 in favour of a simple model.

- PLAN is read-only: its plan-read policy has only `Get*`/`List*`/`Describe*`
  calls and no data-plane reads (no log events, table items or queue
  messages).
- Only the owner's local bootstrap run can change the roles or their
  permissions.
- The DEV and PROD roles trust a GitHub **environment**, not a branch, so the
  environments' deployment-branch rules are what keep other branches out; see
  [GitHub environments](#github-environments).
- The trust policies assume GitHub's default OIDC subject format (the repo
  uses it today). If the org customises the subject claim template, update
  the `sub` values.

### Adding a service

1. Write the service module under `terraform/modules/<service>/` and call it
   from `environments/dev` and `environments/prod`.
2. If the service isn't already in the deployment policy, add its actions to
   the `deploy` policy in `terraform/bootstrap/github-oidc/policies.tf`, and
   its read calls to `plan_read`. If it needs a role passed to it, add a
   **narrow** `iam:PassRole` (that role only, `iam:PassedToService` set to that
   service). Never `iam:*`, `AdministratorAccess` or `PowerUserAccess`.
3. Open a PR; `validate.sh` checks every root.
4. After merge, the account owner applies `bootstrap/github-oidc` locally
   (Bootstrap step 2).
5. Only then can the DEV and PROD workflows deploy the service.

## Bootstrap

Done by the **account owner only**, from a local shell, with short-lived admin
credentials for the AWS account (for example `aws login`). Nothing here uses a
GitHub workflow or a permanent access key. Terraform must be ≥ 1.10 (CI uses
1.15.8). Always apply a saved plan you have read.

**0. Choose the state bucket name:** `canadastartuphub-tfstate-<ACCOUNT_ID>`.
Replace `REPLACE_WITH_STATE_BUCKET_NAME` in all four `backend.tf` files
(`bootstrap/backend`, `bootstrap/github-oidc`, `environments/dev`,
`environments/prod`).

**1. `bootstrap/backend` — first run** (the bucket does not exist yet, so state
starts local and is then migrated into the bucket):

```bash
cd terraform/bootstrap/backend
cp terraform.tfvars.example terraform.tfvars   # set state_bucket_name (gitignored)
mv backend.tf backend.tf.first-run             # local state for this run only
terraform init
terraform plan -out=tfplan
terraform apply tfplan
mv backend.tf.first-run backend.tf
terraform init -migrate-state                  # answer "yes": copies the state into the bucket
terraform state list                           # the bucket and its settings, now read from S3
```

Once `state list` works against S3, delete the local `terraform.tfstate` and
`terraform.tfstate.backup` (both gitignored). Don't commit while `backend.tf`
is renamed. Later runs are plain `terraform init`, `plan -out=tfplan` and
`apply tfplan`.

If the apply fails part-way, keep the local `terraform.tfstate`: it records
what was created. Fix the cause and re-run `plan`/`apply` from the same folder
before restoring `backend.tf`.

**2. `bootstrap/github-oidc`:**

```bash
cd terraform/bootstrap/github-oidc
cp terraform.tfvars.example terraform.tfvars   # set state_bucket_name; see create_github_oidc_provider
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform output                               # the role ARNs for the next step
```

If IAM → Identity providers already lists `token.actions.githubusercontent.com`,
set `create_github_oidc_provider = false` first; an account can hold only one.
Re-run this step whenever the roles or a service's CI permissions change.

**3. GitHub:** create the environments in [GitHub environments](#github-environments)
and enter the values in [Manual values](#manual-values).

**4. Commit the four `backend.tf` bucket names** through the normal flow
(feature branch → `develop` → `main`). The DEV and PROD workflows refuse to run
while a placeholder remains, so from then on DEV and PROD deploy only through
them.

## Manual values

| Value | Source | Enter it in |
|---|---|---|
| State bucket name | chosen in Bootstrap step 0; confirmed by the `state_bucket_name` output of `bootstrap/backend` | `bucket` in `bootstrap/backend/backend.tf`, `bootstrap/github-oidc/backend.tf`, `environments/dev/backend.tf` and `environments/prod/backend.tf`; and `state_bucket_name` in the local `terraform.tfvars` of `bootstrap/backend` and `bootstrap/github-oidc` |
| Region `ca-central-1` | `aws_region` output | Already committed in every backend block and workflow. Nothing to enter. |
| `plan_role_arn` | `bootstrap/github-oidc` output | GitHub → Settings → Secrets and variables → Actions → **Variables** (repository) → `AWS_PLAN_ROLE_ARN` |
| `dev_role_arn` | `bootstrap/github-oidc` output | GitHub → Settings → Environments → **dev** → Environment variables → `AWS_DEPLOY_ROLE_ARN` |
| `prod_role_arn` | `bootstrap/github-oidc` output | GitHub → Settings → Environments → **production** → Environment variables → `AWS_DEPLOY_ROLE_ARN` |

None of these is a secret. Role ARNs go in **variables**, not secrets, because
the OIDC trust policy is the access control and nothing is gained by hiding
the ARN. No AWS access keys exist anywhere.

The deploy workflows fail with a clear error while a `backend.tf` still holds
`REPLACE_WITH_STATE_BUCKET_NAME`. PR plans skip with a notice until
`AWS_PLAN_ROLE_ARN` is set and the placeholder is replaced.

### GitHub environments

Create both **before** entering the role ARNs. A job that names a missing
environment makes GitHub create it with no protection.

| Environment | Deployment branch | Protection | Variable |
|---|---|---|---|
| `dev` | `develop` only | none | `AWS_DEPLOY_ROLE_ARN` (DEV) |
| `production` | `main` only | required reviewers | `AWS_DEPLOY_ROLE_ARN` (PROD) |

The organisation is on GitHub Team, which supports required reviewers on this
private repository.

## Workflows

| Workflow | Trigger | Does |
|---|---|---|
| `terraform-pr.yml` | PR to `develop`/`main` touching `terraform/**` | `validate.sh` (fmt + validate all roots, bootstrap included); plan DEV and PROD with the read-only role. **No apply.** |
| `terraform-dev.yml` | push to `develop` (DEV root, module, workflow) | plan → apply the same saved plan, in environment `dev` |
| `terraform-prod.yml` | push to `main` (PROD root, module, workflow) | plan (read-only role) → **approval** in `production` → apply that saved plan |

There is no bootstrap workflow: the bootstrap roots are validated in PRs and
applied only by the account owner, locally.

## After the first PROD deployment

- DKIM shows `PENDING` until the CNAMEs resolve, usually within minutes and at
  most 72 hours.
- A new SES account is in the **sandbox**, where it can send only to verified
  identities. Sending to `contact@canadatechintelligence.ca` works because the
  apex domain identity is verified. Sending to anyone else needs a production
  access request in the SES console, which is not done in Terraform.
- Not managed here, noted for the owner: there is no `_dmarc` record, and the
  apex SPF includes only `secureserver.net`, not Microsoft 365
  (`spf.protection.outlook.com`). Both affect the existing mailbox, not SES, so
  they are left for a separate decision.

## Local checks (read-only)

Anyone, including an AI assistant, may run these:

```bash
bash terraform/scripts/validate.sh     # fmt + validate; no AWS credentials needed
terraform -chdir=terraform/environments/dev plan -lock=false   # read-only, needs credentials
```
