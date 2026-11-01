
#!/usr/bin/env bash
set -euo pipefail

roots=(
  "bootstrap/State_Bucket/dev"
  "bootstrap/State_Bucket/prod"
  "bootstrap/oidc/envs/dev"
  "bootstrap/oidc/envs/prod"
  "terraform/environments/dev"
  "terraform/environments/prod"
)

for root in "${roots[@]}"; do
  echo "Validating: $root"

  (
    cd "$root"
    terraform init -backend=false -input=false
    terraform validate -no-color
  )
done

echo "All Terraform configurations validated successfully."
