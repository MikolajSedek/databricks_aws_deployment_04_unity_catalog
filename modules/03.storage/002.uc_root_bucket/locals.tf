/*
  Local Values - Unity Catalog Root S3 Bucket Module
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/locals

  Computes the environment-qualified S3 bucket name.
*/

locals {
  bucket_name_with_env = "${var.bucket_name}-${var.environment}"
}
