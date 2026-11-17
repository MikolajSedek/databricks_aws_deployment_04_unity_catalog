/*
  Input Variables - Unity Catalog Metastore Workspace Assignment Module
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_assignment

  Defines input variables for assigning the regional Unity Catalog metastore
  to existing Databricks E2 workspaces.
*/

variable "metastore_id" {
  description = "Unique identifier of the regional Unity Catalog metastore."
  type        = string
}

variable "workspace_ids" {
  description = "Map of logical workspace keys to numeric Databricks workspace IDs to attach to the metastore."
  type        = map(number)
}
