output "app_id" {
  value = aws_amplify_app.this.id
}

output "default_domain" {
  description = "Amplify-provided domain, e.g. <app-id>.amplifyapp.com. Branch serves at <branch>.<default_domain>."
  value       = aws_amplify_app.this.default_domain
}

output "branch_name" {
  value = aws_amplify_branch.this.branch_name
}
