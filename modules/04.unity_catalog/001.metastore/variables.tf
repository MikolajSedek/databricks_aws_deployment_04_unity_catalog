/*
  Input Variables - Unity Catalog Metastore & IAM Permissions Module
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_data_access
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_unity_catalog_policy
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_unity_catalog_assume_role_policy

  Defines input variables for provisioning the Unity Catalog metastore,
  least-privilege AWS IAM role and S3/KMS access policy, KMS grant, and default
  metastore data access configuration.
*/

variable "metastore_name" {
  description = "Name of the Unity Catalog metastore (one metastore per AWS region per account)."
  type        = string
}

variable "aws_region" {
  description = "AWS region where the Unity Catalog metastore is deployed."
  type        = string
}

variable "aws_account_id" {
  description = "12-digit AWS Account ID hosting the Unity Catalog S3 bucket and IAM role."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "The AWS Account ID must be a 12-digit number."
  }
}

variable "databricks_account_id" {
  description = "Databricks Account ID (UUID) used as external_id in the Unity Catalog IAM trust policy."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", var.databricks_account_id))
    error_message = "The Databricks account ID must be a valid UUID."
  }
}

variable "bucket_name" {
  description = "Name of the S3 root storage bucket for the Unity Catalog metastore."
  type        = string
}

variable "kms_key_arn" {
  description = "Customer-managed KMS key ARN encrypting the Unity Catalog S3 root bucket."
  type        = string
}

variable "iam_role_name" {
  description = "Name of the AWS IAM role assumed by Databricks Unity Catalog for metastore storage access."
  type        = string
}

variable "owner_group_name" {
  description = "Account-level group display name assigned as owner of the Unity Catalog metastore (e.g. dbx-platform-admins)."
  type        = string
}

variable "owner" {
  description = "Explicit owner of the Unity Catalog metastore (defaults to owner_group_name)."
  type        = string
  default     = null
}

variable "delta_sharing_scope" {
  description = "Delta Sharing scope on the metastore (INTERNAL or INTERNAL_AND_EXTERNAL)."
  type        = string
  default     = "INTERNAL_AND_EXTERNAL"

  validation {
    condition     = contains(["INTERNAL", "INTERNAL_AND_EXTERNAL"], var.delta_sharing_scope)
    error_message = "delta_sharing_scope must be either INTERNAL or INTERNAL_AND_EXTERNAL."
  }
}

variable "delta_sharing_recipient_token_lifetime_in_seconds" {
  description = "Expiration duration in seconds for Delta Sharing recipient access tokens (default: 2592000 = 30 days)."
  type        = number
  default     = 2592000
}

variable "delta_sharing_organization_name" {
  description = "Organization display name used for Delta Sharing metadata."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Whether to destroy the metastore regardless of its contents."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resource tags to apply to the AWS IAM role and policy."
  type        = map(string)
  default     = {}
}
