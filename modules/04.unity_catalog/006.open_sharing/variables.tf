/*
  Input Variables - Basic Open Delta Sharing Module
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/share
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/recipient
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants

  Defines input variables for provisioning Delta Sharing shares (with shared schemas,
  tables, or volumes), open TOKEN or DATABRICKS recipients, and SELECT share grants.
*/

variable "owner_group_name" {
  description = "Default account-level admin group owning the Delta Sharing shares and recipients (e.g. dbx-platform-admins)."
  type        = string
}

variable "volume_full_names" {
  description = "Optional map of logical volume keys to volume identifiers (full_name, string_shared_as) exported by the volumes module."
  type = map(object({
    full_name        = string
    string_shared_as = string
  }))
  default = {}
}

variable "shares" {
  description = "Map of Delta Sharing share definitions, objects to share, and recipient keys granted SELECT access."
  type = map(object({
    name    = string
    comment = string
    owner   = optional(string)
    objects = optional(list(object({
      name                        = optional(string)
      volume_key                  = optional(string)
      data_object_type            = string
      comment                     = optional(string)
      shared_as                   = optional(string)
      string_shared_as            = optional(string)
      history_data_sharing_status = optional(string)
    })), [])
    recipient_keys = optional(list(string), [])
  }))
  default = {}
}

variable "recipients" {
  description = "Map of Delta Sharing recipient definitions supporting Open Sharing (TOKEN) and Databricks-to-Databricks (DATABRICKS)."
  type = map(object({
    name                               = string
    comment                            = string
    authentication_type                = optional(string, "TOKEN")
    owner                              = optional(string)
    sharing_code                       = optional(string)
    data_recipient_global_metastore_id = optional(string)
    allowed_ip_addresses               = optional(list(string), [])
    properties                         = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.recipients : contains(["TOKEN", "DATABRICKS"], coalesce(v.authentication_type, "TOKEN"))
    ])
    error_message = "Recipient authentication_type must be either TOKEN or DATABRICKS."
  }
}
