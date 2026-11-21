---
name: repo-layout
description: The three Terraform stacks in this repo, their dev/prod roots, where CI applies each one, and what is NOT managed here
metadata:
  type: project
---

**Corrected 2026-11-21 against the working tree.** The previous version
described an `infra/` stack holding `amplify-app` and `amplify-domain`
modules, a single `terraform.yml` workflow, a
`canadastartupdirectory-tfstate` bucket and an `infra/scripts/tf_validate.py`.
None of those exists. It also called the repo prod-only, which it is not.

**Three** Terraform stacks, all `ca-central-1`, each with its own **dev and
prod** root — six roots in total, which `infrastructure/scripts/validate.sh`
enumerates authoritatively:

- `bootstrap/State_Bucket/{dev,prod}` — the S3 state buckets themselves
  (bucket, versioning, encryption, public-access block). Chicken-and-egg, so
  it keeps **local state**: no `backend.tf`, and `*.tfstate` is gitignored.
  Applied manually from a local machine.
- `bootstrap/oidc/envs/{dev,prod}` — GitHub OIDC provider + CI roles
  (module: `bootstrap/oidc/modules/github-oidc`). Applied manually, not by
  CI. State key `bootstrap/oidc/{dev,prod}/terraform.tfstate`.
- `infrastructure/envs/{dev,prod}` — the application stack. Modules:
  **`cognito`**, **`ses`**, **`route53-zone`** (dev) and
  **`route53-delegation`** (prod). State key
  `envs/{dev,prod}/terraform.tfstate`.

State buckets are `cti-terraform-state-dev-ca-central-1` and
`cti-terraform-state-prod-ca-central-1` — one per environment.

## What this repo does NOT manage

**The AWS Amplify applications are not in Terraform.** There is no
`aws_amplify_app` resource and no Amplify module anywhere in the repo; both
the dev and prod Amplify apps are managed by hand **in the AWS console**. The
seam is visible in `infrastructure/envs/{dev,prod}/outputs.tf`, which emits
`ses_amplify_compute_role_arn` described as "Set as the compute role on the
dev Amplify app (console)" — Terraform creates the role, a human attaches it.

Consequences worth knowing before planning work:

- **Amplify environment variables are console state**, not code.
- **Anything Amplify creates implicitly is unmanaged**, including the
  CloudWatch log groups for its SSR compute. That is why a search for
  `aws_cloudwatch_log_group` in this repo returns nothing while log groups do
  exist in the account — see the CloudWatch retention audit (2026-11-21).
- A `terraform destroy` here would not touch the running sites.

## CI

Three workflows, not one:

- `.github/workflows/terraform-dev.yml` — push to **develop**, paths
  `infrastructure/envs/dev/**`, `infrastructure/modules/**` or the workflow
  itself. Plan, then apply only on explicit authorization.
- `.github/workflows/terraform-prod.yml` — push to **main**, paths
  `infrastructure/envs/prod/**`, `infrastructure/modules/**` or the workflow
  itself.
- `.github/workflows/terraform-pr.yml` — plan only, never apply. A PR to
  `develop` plans against the DEV account, a PR to `main` against PROD.

So a change under `infrastructure/modules/**` triggers BOTH environment
workflows on their respective branches, and **neither bootstrap stack is ever
applied by CI**. AWS auth is GitHub OIDC throughout; OAuth provider secrets
come from GitHub Environments.

Local validation is `infrastructure/scripts/validate.sh`: `terraform init
-backend=false` and `terraform validate` over all six roots. There is no
pre-commit config and no Python helper.

**It needs AWS credentials in practice, despite `-backend=false`.** Verified
2026-11-21: `bootstrap/State_Bucket/*` validates fine because it has no
backend, but in a working copy where an S3-backed root has already been
initialized, `.terraform/` holds that backend's configuration and `init` still
resolves credentials — so without a live session the run stops at
`bootstrap/oidc/envs/dev` with "No valid credential sources found". Clear the
root's `.terraform/` to validate offline, or run it with credentials. It
grants no permissions and reads no state either way; it just cannot get past
`init`.

**Claude never applies.** `terraform apply`/`destroy` and mutating AWS CLI
calls are the owner's, through the workflows above or locally for bootstrap.
