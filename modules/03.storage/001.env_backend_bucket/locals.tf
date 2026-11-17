/*
  Local Values - S3 Backend Bucket Module
  Documentation: https://developer.hashicorp.com/terraform/language/values/locals

  Calculates environment-suffixed bucket naming conventions for backend storage.
*/

locals {
  bucket_name_with_env = "${var.bucket_name}-${var.environment}"
}
