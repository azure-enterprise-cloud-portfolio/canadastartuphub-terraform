
output "github_actions_role_arn" {
  description = "Production IAM role ARN used by GitHub Actions for Terraform deployments."
  value       = module.github_oidc.github_actions_role_arn
}

output "oidc_provider_arn" {
  description = "AWS IAM OIDC provider ARN for GitHub Actions."
  value       = module.github_oidc.oidc_provider_arn
}
