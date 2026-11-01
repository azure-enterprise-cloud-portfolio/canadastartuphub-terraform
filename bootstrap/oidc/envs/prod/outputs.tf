output "github_actions_role_arn" {
  description = "Set this as the AWS_ROLE_ARN secret in the GitHub repository."
  value       = module.github_oidc.github_actions_role_arn
}

output "oidc_provider_arn" {
  value = module.github_oidc.oidc_provider_arn
}
