# Bootstrap 1 of 2: the central Terraform state bucket.
#
# ONE bucket for the whole project — shared, production-controlled. Every
# other root stores its state here under its own key, set in that root's
# backend.tf (e.g. bootstrap/github-oidc/terraform.tfstate, dev/terraform.tfstate).
# Every key must end in .tfstate so the delete protections in the bucket
# policy below apply to it.
#
# Applied ONLY by the account owner from their own local CLI. No GitHub
# workflow applies it, and an AI assistant never runs apply or destroy here.
#
# Protection model: only principals matching var.admin_principal_arns can
# change the bucket's configuration or delete state. No one can purge old
# state versions; the lifecycle rule expires them. The account root user can
# still delete the bucket policy (AWS lockout recovery) and is break-glass only.

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "state" {
  bucket        = var.state_bucket_name
  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle {
    prevent_destroy = true
  }
}

# Old state versions are the rollback path; keep them for a bounded window.
resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_state_retention_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.state]
}

data "aws_iam_policy_document" "state_bucket" {
  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.state.arn, "${aws_s3_bucket.state.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid       = "DenyTlsBelow12"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.state.arn, "${aws_s3_bucket.state.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }
  }

  # Deleting the bucket requires an admin principal to remove this statement first.
  statement {
    sid       = "DenyBucketDeletion"
    effect    = "Deny"
    actions   = ["s3:DeleteBucket"]
    resources = [aws_s3_bucket.state.arn]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  # Only admin principals may change how the bucket is configured.
  statement {
    sid    = "DenyConfigChangesExceptAdmin"
    effect = "Deny"
    actions = [
      "s3:PutBucketPolicy",
      "s3:DeleteBucketPolicy",
      "s3:PutBucketVersioning",
      "s3:PutEncryptionConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketOwnershipControls",
      "s3:PutBucketAcl",
      "s3:PutBucketObjectLockConfiguration",
      "s3:PutReplicationConfiguration",
      "s3:PutBucketNotification",
      "s3:PutBucketLogging",
      "s3:PutBucketTagging",
      "s3:PutBucketCORS",
      "s3:PutBucketWebsite",
    ]
    resources = [aws_s3_bucket.state.arn]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values   = var.admin_principal_arns
    }
  }

  # No one purges old state versions; the lifecycle rule expires them.
  statement {
    sid       = "DenyStateVersionDeletion"
    effect    = "Deny"
    actions   = ["s3:DeleteObjectVersion"]
    resources = ["${aws_s3_bucket.state.arn}/*.tfstate"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  # CI roles write state but never delete it.
  statement {
    sid       = "DenyStateDeletionExceptAdmin"
    effect    = "Deny"
    actions   = ["s3:DeleteObject"]
    resources = ["${aws_s3_bucket.state.arn}/*.tfstate"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values   = var.admin_principal_arns
    }
  }

  # Dev account CI roles: dev/* only. Their own IAM policies narrow it further
  # (the dev plan role can only read).
  statement {
    sid       = "AllowDevCiList"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.state.arn]

    principals {
      type        = "AWS"
      identifiers = var.dev_state_principal_arns
    }
  }

  statement {
    sid       = "AllowDevCiState"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.state.arn}/dev/*"]

    principals {
      type        = "AWS"
      identifiers = var.dev_state_principal_arns
    }
  }
}

resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id
  policy = data.aws_iam_policy_document.state_bucket.json

  depends_on = [aws_s3_bucket_public_access_block.state]

  lifecycle {
    prevent_destroy = true
  }
}