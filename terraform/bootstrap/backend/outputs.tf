# These values are copied BY HAND into the other roots. No other state reads
# this one. Where each value goes is in terraform/README.md, "Manual values".

output "state_bucket_name" {
  description = "Central state bucket. Confirms the name hand-entered in every root's backend.tf."
  value       = aws_s3_bucket.state.bucket
}

output "state_bucket_arn" {
  description = "ARN of the central state bucket. Hand-entered in bootstrap/github-oidc to scope each CI role's state access to its own key."
  value       = aws_s3_bucket.state.arn
}

output "aws_region" {
  description = "Region of the bucket. Every backend block uses it."
  value       = var.aws_region
}

output "aws_account_id" {
  description = "Account that owns the bucket (reference only)."
  value       = data.aws_caller_identity.current.account_id
}

output "admin_principal_arns" {
  description = "Role ARN patterns allowed to change the state bucket's configuration or delete state. Every other principal is denied by the bucket policy."
  value       = var.admin_principal_arns
}