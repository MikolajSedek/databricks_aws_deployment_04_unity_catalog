/*
  Data Sources - Dev Environment
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/mws_workspaces
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/current_user
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/group
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/service_principal

  Retrieves pre-existing Databricks Account-level groups and service principals
  provisioned in Project 02 (02_setup_identity_management) and existing Databricks
  E2 workspaces provisioned in Project 03 (03_workspaces_and_compute_management).
*/

/* 1. Discover all existing Databricks E2 Workspaces in the Account (from Project 03) */
data "databricks_mws_workspaces" "all" {
  provider = databricks.mws
}

/* 2. Primary Governance Workspace URL (Data Engineering) */
data "databricks_current_user" "data_engineering" {
  provider = databricks.mws
  provider_config {
    workspace_id = tostring(data.databricks_mws_workspaces.all.ids[local.workspace_names.data_engineering])
  }
}

/* 3. Databricks Account-level Groups provisioned in Project 02 */
data "databricks_group" "platform_admins" {
  provider     = databricks.mws
  display_name = "dbx-platform-admins"
}

data "databricks_group" "data_engineers" {
  provider     = databricks.mws
  display_name = "dbx-data-engineers"
}

data "databricks_group" "data_scientists" {
  provider     = databricks.mws
  display_name = "dbx-data-scientists"
}

data "databricks_group" "data_analysts" {
  provider     = databricks.mws
  display_name = "dbx-data-analysts"
}
