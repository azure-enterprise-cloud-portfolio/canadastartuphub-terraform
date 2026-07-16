---
name: repo-layout
description: How the two Terraform stacks in this repo relate and where CI runs
metadata:
  type: project
---

Two independent Terraform stacks, both targeting `ca-central-1`, prod-only:

- `bootstrap/` — one-time foundation: GitHub OIDC provider + CI role
  (`bootstrap/modules/github-oidc`). Applied manually from a local machine,
  not by CI.
- `infra/` — the app stack: Amplify app + custom domain
  (`infra/modules/amplify-app`, `infra/modules/amplify-domain`). Applied by
  GitHub Actions (`.github/workflows/terraform.yml`) via the OIDC role;
  state lives in the `canadastartupdirectory-tfstate` S3 bucket.

CI only triggers on `infra/**` changes — bootstrap changes never auto-apply.
Local dev is native Windows, so bash-based pre-commit terraform hooks are
replaced with direct `terraform` calls and `infra/scripts/tf_validate.py`.
