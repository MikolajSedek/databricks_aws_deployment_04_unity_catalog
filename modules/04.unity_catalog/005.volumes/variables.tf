/*
  Input Variables - Unity Catalog Volumes (Managed & Optional External) Module
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/volume
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/storage_credential
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/external_location
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants

  Defines input variables for provisioning Unity Catalog MANAGED volumes and
  optional EXTERNAL volumes (including their AWS IAM role, storage credential,
  external location, and RBAC grants).
*/

variable "aws_account_id" {
  description = "12-digit AWS Account ID used when provisioning optional external storage credentials."
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

variable "owner_group_name" {
  description = "Default account-level admin group owning the volumes and external locations (e.g. dbx-platform-admins)."
  type        = string
}

variable "schema_names" {
  description = "Map of logical schema keys to resolved catalog_name, schema_name, and full_name."
  type = map(object({
    catalog_name = string
    schema_name  = string
    full_name    = string
  }))
}

variable "external_locations" {
  description = "Optional map of external storage locations (IAM role, S3 bucket, KMS key, URL prefix, and grants) for EXTERNAL volumes."
  type = map(object({
    name           = string
    bucket_name    = string
    kms_key_arn    = string
    iam_role_name  = string
    s3_subpath     = optional(string, "external-volumes")
    comment        = optional(string, "External S3 location for Unity Catalog volumes")
    isolation_mode = optional(string, "ISOLATION_MODE_OPEN")
    read_only      = optional(bool, false)
    force_destroy  = optional(bool, false)
    grants = optional(list(object({
      principal  = string
      privileges = list(string)
    })), [])
  }))
  default = {}
}

variable "volumes" {
  description = "Map of Unity Catalog volume definitions supporting MANAGED and optional EXTERNAL volume types with RBAC grants."
  type = map(object({
    schema_key            = string
    name                  = string
    volume_type           = optional(string, "MANAGED")
    comment               = string
    owner                 = optional(string)
    external_location_key = optional(string)
    external_subpath      = optional(string)
    grants = optional(list(object({
      principal  = string
      privileges = list(string)
    })), [])
  }))

  validation {
    condition = alltrue([
      for k, v in var.volumes : contains(["MANAGED", "EXTERNAL"], coalesce(v.volume_type, "MANAGED"))
    ])
    error_message = "volume_type must be either MANAGED or EXTERNAL."
  }

  validation {
    condition = alltrue([
      for k, v in var.volumes :
      coalesce(v.volume_type, "MANAGED") == "MANAGED" || v.external_location_key != null
    ])
    error_message = "EXTERNAL volumes must specify a valid external_location_key."
  }
}

variable "tags" {
  description = "Additional AWS tags for optional external location IAM roles and policies."
  type        = map(string)
  default     = {}
}
