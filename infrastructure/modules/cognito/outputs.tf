
output "user_pool_id" {
  description = "CTI Cognito User Pool ID"
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_client_id" {
  description = "CTI web application client ID"
  value       = aws_cognito_user_pool_client.web.id
}

output "user_pool_arn" {
  description = "CTI Cognito User Pool ARN"
  value       = aws_cognito_user_pool.this.arn
}

output "admin_group_name" {
  description = "Cognito administrator group"
  value       = aws_cognito_user_group.admin.name
}
