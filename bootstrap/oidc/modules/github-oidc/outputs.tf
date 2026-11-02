output "github_actions_role_arn" {
  description = "IAM role ARN used by GitHub Actions to deploy Terraform infrastructure."
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "IAM role name used by GitHub Actions (for attaching policies)."
  value       = aws_iam_role.github_actions.name
}

output "oidc_provider_arn" {
  description = "AWS IAM OIDC provider ARN for GitHub Actions authentication."
  value       = local.github_oidc_provider_arn
}