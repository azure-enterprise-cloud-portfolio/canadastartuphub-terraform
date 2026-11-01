# bootstrap/backend

Creates the central S3 bucket for all Terraform state. Bootstrap 1 of 2 — run before `bootstrap/github-oidc`.

**Applied only by the account owner from a local CLI.** No workflow or AI assistant applies it.

## Creates

- S3 bucket `canadatechintelligence-tfstate-<account-id>` (`ca-central-1`)
- Versioning, AES256 encryption, public access blocked, ACLs disabled
- Lifecycle: old state versions expire after 90 days
- Deny-only bucket policy (below)

This root's state: `bootstrap/backend/terraform.tfstate`

## Protection

- HTTPS and TLS 1.2+ only
- Bucket deletion denied
- Only `admin_principal_arns` can change bucket config or delete `*.tfstate`
- No one can delete old state versions
- `prevent_destroy` on all protecting resources
- `allowed_account_ids` blocks the wrong account

Root user can still remove the policy — break-glass only, MFA on.

## Prerequisites

- Terraform >= 1.11, AWS CLI v2
- SSO session with **AWSAdministratorAccess**

```powershell
aws sso login --profile <profile>
$env:AWS_PROFILE = "<profile>"
aws sts get-caller-identity   # must show AWSAdministratorAccess
```

## terraform.tfvars (gitignored)

```hcl
state_bucket_name = "canadatechintelligence-tfstate-<account-id>"
aws_account_id    = "<account-id>"

admin_principal_arns = [
  "arn:aws:iam::<account-id>:role/aws-reserved/sso.amazonaws.com/*AWSReservedSSO_AWSAdministratorAccess_*"
]
```

## Run

```powershell
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

`Instance cannot be destroyed` = `prevent_destroy` working. Don't bypass it.

## New root or environment

No change here. In the new root's `backend.tf`, use a unique key ending in `.tfstate`:

```hcl
terraform {
  backend "s3" {
    bucket       = "canadatechintelligence-tfstate-<account-id>"
    key          = "staging/terraform.tfstate"
    region       = "ca-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

## Restore old state

```powershell
aws s3api list-object-versions --bucket <bucket> --prefix dev/terraform.tfstate
aws s3api get-object --bucket <bucket> --key dev/terraform.tfstate --version-id <id> restored.tfstate
```

Then `terraform state push restored.tfstate` from that root.

## Troubleshooting

| Error | Fix |
|---|---|
| `AWS account ID not allowed` | Switch to the correct account |
| `AccessDenied` | Use AWSAdministratorAccess |
| `Instance cannot be destroyed` | Revert the change forcing replacement |