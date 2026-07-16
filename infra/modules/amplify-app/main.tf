# Service role Amplify assumes for SSR compute, logs, and deployments.
resource "aws_iam_role" "amplify" {
  name = "${var.app_name}-amplify-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "amplify.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "amplify" {
  role       = aws_iam_role.amplify.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
}

resource "aws_amplify_app" "this" {
  name                 = var.app_name
  repository           = var.repository_url
  access_token         = var.github_token
  platform             = "WEB_COMPUTE" # Next.js SSR
  iam_service_role_arn = aws_iam_role.amplify.arn

  # Build config lives in amplify.yml in the app repo;
  # Amplify auto-detects Next.js when it's absent.
  enable_branch_auto_build = true

  environment_variables = var.environment_variables

  tags = var.tags
}

resource "aws_amplify_branch" "this" {
  app_id            = aws_amplify_app.this.id
  branch_name       = var.branch_name
  stage             = "PRODUCTION"
  enable_auto_build = true
  framework         = "Next.js - SSR"

  tags = var.tags
}
