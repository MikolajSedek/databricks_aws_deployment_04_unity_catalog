/*
  Input Variables - Unity Catalog Schemas & RBAC Module
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/schema
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants

  Defines input variables for provisioning schemas (databases) within Unity Catalog
  catalogs and applying schema-level RBAC grants.
*/

variable "catalog_names" {
  description = "Map of logical catalog keys to resolved Unity Catalog names."
  type        = map(string)
}

variable "owner_group_name" {
  description = "Default account-level admin group owning the schemas (e.g. dbx-platform-admins)."
  type        = string
}

variable "schemas" {
  description = "Map of schema definitions keyed by logical identifier, including parent catalog_key and RBAC grants."
  type = map(object({
    catalog_key                    = string
    name                           = string
    comment                        = string
    owner                          = optional(string)
    enable_predictive_optimization = optional(string, "INHERIT")
    force_destroy                  = optional(bool, false)
    properties                     = optional(map(string), {})
    grants = optional(list(object({
      principal  = string
      privileges = list(string)
    })), [])
  }))
}
