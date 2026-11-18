module "cognito" {
  source = "../../modules/cognito"

  project     = var.project
  environment = var.environment
}