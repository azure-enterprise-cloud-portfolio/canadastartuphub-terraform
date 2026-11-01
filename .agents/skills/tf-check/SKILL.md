---
name: tf-check
description: Run this repo's local Terraform quality gates (fmt, validate, tflint, gitleaks) the same way CI and pre-commit do. Use before committing any .tf change or when the user asks to check/lint/validate Terraform.
---

# Terraform quality checks

Run these from the repo root. This is a native-Windows machine — do not use
bash-based pre-commit-terraform hooks.

## Steps

1. **Format check** (matches CI):
   ```
   terraform fmt -check -diff -recursive infra
   terraform fmt -check -diff -recursive bootstrap
   ```
   If it fails, run without `-check` to fix, then show the diff to the user.

2. **Validate** (uses the repo's Windows-safe wrapper, which handles
   `terraform init -backend=false` per directory):
   ```
   python infra/scripts/tf_validate.py
   ```

3. **TFLint** (optional — only if `tflint` is on PATH):
   ```
   tflint --config=infra/.tflint.hcl --recursive
   ```

4. **Secrets scan** (only if `gitleaks` is on PATH):
   ```
   gitleaks detect --config=infra/.gitleaks.toml --no-banner
   ```

## Rules

- Never run `terraform plan` or `apply` against prod state as part of a
  check — plans need AWS credentials and touch the real backend. Only plan
  when the user explicitly asks.
- `bootstrap/` is applied manually, never by CI. Flag any change there
  prominently.
- Report each gate's pass/fail explicitly; don't summarize failures away.
