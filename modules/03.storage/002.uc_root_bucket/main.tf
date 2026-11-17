/*
  Unity Catalog S3 Root Storage Bucket Definition
  Documentation:
    - https://docs.databricks.com/aws/en/data-governance/unity-catalog/get-started
    - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket

  Provisions a hardened Amazon S3 bucket for Unity Catalog storage:
    - Server-side encryption with customer-managed KMS key (SSE-KMS) and bucket key enabled.
    - S3 object versioning suspended/disabled per Databricks Unity Catalog recommendations
      (Delta Lake natively manages table version history via transaction logs).
    - S3 Block Public Access enabled across all four public access flags.
    - BucketOwnerEnforced object ownership controls (disables legacy ACLs).
    - Lifecycle rule to abort incomplete multipart uploads after 7 days.
*/

resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name_with_env
  force_destroy = var.force_destroy

  tags = merge(
    {
      Name        = local.bucket_name_with_env
      Environment = var.environment
      Purpose     = "UnityCatalogStorage"
    },
    var.tags
  )
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Disabled"
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
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
