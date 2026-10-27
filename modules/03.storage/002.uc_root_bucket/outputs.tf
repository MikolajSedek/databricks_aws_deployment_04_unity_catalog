/*
  Output Values - Unity Catalog Root S3 Bucket Module
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/outputs

  Exports the S3 bucket name for downstream consumption by the Unity Catalog
  metastore, catalogs, and external volume modules.
*/

output "bucket_name" {
  description = "The resolved name (ID) of the Unity Catalog S3 bucket."
  value       = aws_s3_bucket.this.id
}
