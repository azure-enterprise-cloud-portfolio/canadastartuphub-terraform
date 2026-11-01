# Central state bucket, created by terraform/bootstrap/backend. ONE bucket is
# shared by every environment, with one key per environment. The bucket name is
# entered BY HAND: replace the placeholder with bootstrap/backend's
# `state_bucket_name` output. It is never looked up from bootstrap state.
# use_lockfile is S3-native state locking (Terraform >= 1.10); no DynamoDB.
terraform {
  backend "s3" {
    bucket       = "REPLACE_WITH_STATE_BUCKET_NAME"
    key          = "prod/terraform.tfstate"
    region       = "ca-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
