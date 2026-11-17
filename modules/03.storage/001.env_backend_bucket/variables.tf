/*
  Input Variables - S3 Backend Bucket Module
  Documentation: https://developer.hashicorp.com/terraform/language/values/variables

  Defines input variables for bucket naming, environment tags, KMS encryption key ARN,
  and destruction safeguards.
*/

variable "bucket_name" {
  description = "Base name of the S3 bucket for Terraform backend storage"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9.-]+$", var.bucket_name))
    error_message = "The bucket_name must consist only of lowercase letters, numbers, hyphens, and periods."
  }
}

variable "environment" {
  description = "Environment for TF deployment"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for S3 server-side encryption"
  type        = string

  validation {
    condition     = startswith(var.kms_key_arn, "arn:aws") && can(regex(":kms:", var.kms_key_arn))
    error_message = "The KMS key ARN must be a valid AWS KMS ARN (starting with arn:aws and containing :kms:)."
  }
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the bucket"
  type        = map(string)
  default     = {}
}
