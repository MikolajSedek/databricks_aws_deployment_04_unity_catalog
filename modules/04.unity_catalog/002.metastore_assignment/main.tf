/*
  Unity Catalog Metastore Workspace Assignment Configuration
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_assignment
    - https://docs.databricks.com/aws/en/data-governance/unity-catalog/get-started

  Links the regional Unity Catalog metastore to each existing Databricks E2 workspace
  (Data Engineering, Data Science, Data Analytics) using the account-level MWS provider.
*/

resource "databricks_metastore_assignment" "this" {
  for_each     = var.workspace_ids
  provider     = databricks.mws
  workspace_id = each.value
  metastore_id = var.metastore_id
}
