/*
  Input Variables - KMS Key Module
  Documentation: https://developer.hashicorp.com/terraform/language/values/variables

  Defines input variables for configuring KMS key aliases, descriptions,
  rotation policies, and deletion window durations.
*/

variable "kms_key_description" {
  description = "Custom KMS key description"
  type        = string
}

variable "enable_key_rotation" {
  description = "KMS key rotation enablement"
  type        = bool
  default     = true
}

variable "deletion_window_in_days" {
  description = "Number of days for key deletion (must be between 7 and 30 days)"
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "The KMS key deletion window must be between 7 and 30 days."
  }
}

variable "kms_key_alias" {
  description = "KMS key alias"
  type        = string
}

variable "environment" {
  description = "Environment for TF deployment"
  type        = string
}
