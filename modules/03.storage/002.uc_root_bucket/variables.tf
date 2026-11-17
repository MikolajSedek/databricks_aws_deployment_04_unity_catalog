/*
  Input Variables - Unity Catalog Root S3 Bucket Module
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/variables
    - https://docs.databricks.com/aws/en/data-governance/unity-catalog/get-started

  Defines input parameters for provisioning a hardened S3 bucket used as the
  Unity Catalog metastore root storage or optional external volume storage.
*/

variable "bucket_name" {
  description = "Base name of the S3 bucket for Unity Catalog storage (environment suffix is appended automatically)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,55}[a-z0-9]$", var.bucket_name))
    error_message = "The bucket_name must follow AWS S3 naming conventions (lowercase alphanumeric and hyphens)."
  }
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "kms_key_arn" {
  description = "Customer-managed KMS key ARN used for S3 server-side encryption (SSE-KMS)."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/[a-f0-9-]+$", var.kms_key_arn))
    error_message = "The kms_key_arn must be a valid AWS KMS key ARN."
  }
}

variable "force_destroy" {
  description = "Whether all objects should be deleted from the bucket when the bucket is destroyed."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional resource tags to apply to the Unity Catalog S3 bucket."
  type        = map(string)
  default     = {}
}
