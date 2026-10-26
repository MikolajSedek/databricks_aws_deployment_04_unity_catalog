/*
  Input Variables - Unity Catalog Secrets & Workspace Secret Scopes Module
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_uc
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_scope
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_acl

  Defines input variables for provisioning native Unity Catalog secrets
  (databricks_secret_uc within 3-level namespace schemas) with READ_SECRET/MANAGE
  grants, alongside optional workspace secret scopes (databricks_secret_scope).
*/

variable "owner_group_name" {
  description = "Default account-level admin group owning the Unity Catalog secrets (e.g. dbx-platform-admins)."
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

variable "uc_secrets" {
  description = "Map of Unity Catalog secrets (databricks_secret_uc) scoped to schemas with RBAC grants."
  type = map(object({
    schema_key  = string
    name        = string
    value       = string
    comment     = string
    owner       = optional(string)
    expire_time = optional(string)
    grants = optional(list(object({
      principal  = string
      privileges = list(string)
    })), [])
  }))
  default = {}
}

variable "secret_scopes" {
  description = "Optional map of workspace-level Databricks secret scopes, keys, and ACLs."
  type = map(object({
    scope_name = string
    secrets = optional(map(object({
      key          = string
      string_value = string
    })), {})
    acls = optional(list(object({
      principal  = string
      permission = string
    })), [])
  }))
  default = {}
}
