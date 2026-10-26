/*
  Amazon S3 Remote State Backend Bucket Definition
  Documentation:
    - https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html
    - https://developer.hashicorp.com/terraform/language/settings/backends/s3

  Provisions a secure Amazon S3 bucket for storing Terraform remote state files:
    - Object versioning enabled for state history and rollback protection.
    - Server-side encryption with AWS KMS (SSE-KMS) and bucket keys enabled.
    - S3 Block Public Access enabled across all four public access controls.
    - Bucket ownership controls enforced (disabling legacy ACLs).
*/

resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name_with_env
  force_destroy = var.force_destroy

  tags = merge(
    {
      Name        = local.bucket_name_with_env
      Environment = var.environment
    },
    var.tags
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "cleanup-old-state-versions"
    status = "Enabled"

    # This targets only the older, historical versions
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
