/*
  Input Variables - Unity Catalog Catalogs, Workspace Bindings & RBAC Module
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/catalog
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_binding
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants

  Defines input variables for provisioning Unity Catalog catalogs (sharing the
  metastore root S3 bucket with distinct prefix paths), configuring ISOLATED or OPEN
  workspace bindings, and enforcing role-based access control (RBAC) grants.
*/

variable "uc_root_bucket_name" {
  description = "Name of the shared Unity Catalog root S3 bucket where catalog managed prefixes reside."
  type        = string
}

variable "owner_group_name" {
  description = "Default account-level admin group owning the catalogs (e.g. dbx-platform-admins)."
  type        = string
}

variable "catalogs" {
  description = "Map of catalog definitions including isolation mode, workspace bindings, and RBAC grants."
  type = map(object({
    name                           = string
    comment                        = string
    isolation_mode                 = optional(string, "ISOLATED")
    enable_predictive_optimization = optional(string, "ENABLE")
    force_destroy                  = optional(bool, false)
    owner                          = optional(string)
    storage_subpath                = optional(string)
    properties                     = optional(map(string), {})
    workspace_bindings = optional(list(object({
      workspace_id = number
      binding_type = optional(string, "BINDING_TYPE_READ_WRITE")
    })), [])
    grants = optional(list(object({
      principal  = string
      privileges = list(string)
    })), [])
  }))

  validation {
    condition = alltrue([
      for k, v in var.catalogs : contains(["ISOLATED", "OPEN"], coalesce(v.isolation_mode, "ISOLATED"))
    ])
    error_message = "Catalog isolation_mode must be either ISOLATED or OPEN."
  }
}
