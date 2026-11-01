# Role ARNs are copied BY HAND into GitHub.

output "prod_plan_role_arn" {
  description = "Prod account plan role (read-only)."
  value       = aws_iam_role.prod["plan"].arn
}

output "prod_deploy_role_arn" {
  description = "Prod account deploy role. GitHub: environment \"production\" variable AWS_DEPLOY_ROLE_ARN."
  value       = aws_iam_role.prod["prod"].arn
}

output "dev_plan_role_arn" {
  description = "Dev account plan role (read-only)."
  value       = aws_iam_role.dev["plan"].arn
}

output "dev_deploy_role_arn" {
  description = "Dev account deploy role. GitHub: environment \"dev\" variable AWS_DEPLOY_ROLE_ARN."
  value       = aws_iam_role.dev["dev"].arn
}