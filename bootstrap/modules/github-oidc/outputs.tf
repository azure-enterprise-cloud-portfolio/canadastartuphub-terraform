output "github_actions_role_arn" {
  description = "Set this as the AWS_ROLE_ARN secret in the GitHub repository."
  value       = aws_iam_role.github_actions.arn
}

output "oidc_provider_arn" {
  value = local.github_oidc_provider_arn
}
