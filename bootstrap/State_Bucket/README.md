# Canada Tech Intelligence — Terraform State Bucket

## Overview

Manages AWS S3 buckets for Canada Tech Intelligence Terraform state storage across Development and Production environments.

**Terraform is the primary deployment method. PowerShell scripts are optional.**

## AWS Configuration

| Setting | Development | Production |
|---|---|---|
| AWS Account | Configure per environment | `285034436054` |
| Region | `ca-central-1` | `ca-central-1` |
| S3 Bucket | `cti-terraform-state-dev-ca-central-1` | `cti-terraform-state-prod-ca-central-1` |
| Encryption | SSE-S3 (AES-256) | SSE-S3 (AES-256) |
| Versioning | Enabled | Enabled |
| Public Access | Blocked | Blocked |
| Terraform Protection | `prevent_destroy = true` | `prevent_destroy = true` |

## Directory Structure

```text
State_Bucket/
├── backups/
│   ├── dev/
│   └── prod/
├── dev/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── versions.tf
├── prod/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── versions.tf
├── Scripts/
│   ├── CTIDevTerraformState.ps1
│   └── CTIProdTerraformState.ps1
└── README.md
```

## 1. Create and Manage S3 Buckets

Navigate to `State_Bucket/dev/` or `State_Bucket/prod/`.

```powershell
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Terraform manages:

- S3 bucket creation and tagging.
- Versioning and SSE-S3 encryption.
- Block Public Access settings.
- Lifecycle protection using `prevent_destroy`.

For an existing bucket, import it into Terraform rather than attempting to recreate it.

## 2. Optional PowerShell Scripts

PowerShell scripts are retained for optional initial setup or administration.

From `State_Bucket/`:

```powershell
.\Scripts\CTIDevTerraformState.ps1 -WhatIf
.\Scripts\CTIProdTerraformState.ps1 -WhatIf
```

Use these scripts only when needed. Terraform remains the authoritative infrastructure configuration.

## 3. Terraform State Backup

The bootstrap Terraform state remains local.

| Environment | Local working state |
|---|---|
| Dev | `dev/terraform.tfstate` |
| Prod | `prod/terraform.tfstate` |

### Development S3 Backup

Run from `State_Bucket/dev/`:

```powershell
aws s3 cp ".\terraform.tfstate" "s3://cti-terraform-state-dev-ca-central-1/bootstrap/state-bucket/dev/backups/terraform.tfstate"
```

### Production S3 Backup

Run from `State_Bucket/prod/`:

```powershell
aws s3 cp ".\terraform.tfstate" "s3://cti-terraform-state-prod-ca-central-1/bootstrap/state-bucket/prod/backups/terraform.tfstate"
```

These are backup copies, not active Terraform backends. Upload updated backups after successful infrastructure changes.

Maintain an additional encrypted backup outside the bucket being managed.

## 4. Terraform Verification

```powershell
terraform state list
terraform plan
```

Expected output after successful configuration:

```text
No changes. Your infrastructure matches the configuration.
```

## Security

- Never commit `.tfstate`, `.tfplan`, or backup files to GitHub.
- Commit `.terraform.lock.hcl`.
- Enable S3 versioning, encryption, and Block Public Access.
- Use least-privilege IAM access.
- Keep `prevent_destroy = true` to protect against Terraform-initiated bucket destruction.
- Review Terraform plans before applying changes.

**Note:** `prevent_destroy` does not prevent deletion through the AWS Console or CLI.

## Status

| Environment | Status |
|---|---|
| Development | S3 bucket created and managed by Terraform |
| Production | S3 bucket created/imported and managed by Terraform |
| Bootstrap state | Local |
| S3 state backups | Manual upload |
| GitHub OIDC | Managed separately |

**Last verification:** Terraform deployment completed successfully for both environments. Both should be checked with `terraform plan` after future changes.