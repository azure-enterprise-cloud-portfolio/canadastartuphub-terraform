#!/usr/bin/env bash
# fmt + validate every Terraform root and the SES module, with no AWS access.
# `init -backend=false` skips the S3 backend, so this needs neither credentials
# nor the state bucket. Used by .github/workflows/terraform-pr.yml and locally:
#   bash terraform/scripts/validate.sh
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> terraform fmt -check -recursive"
terraform fmt -check -recursive -diff .

for dir in bootstrap/backend bootstrap/github-oidc modules/ses environments/dev environments/prod; do
  echo "==> ${dir}: init -backend=false && validate"
  terraform -chdir="${dir}" init -backend=false -input=false -no-color >/dev/null
  terraform -chdir="${dir}" validate -no-color
done
