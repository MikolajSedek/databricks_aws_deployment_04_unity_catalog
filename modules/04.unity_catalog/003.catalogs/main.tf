/*
  Unity Catalog Catalogs, Workspace Bindings, and Role-Based Access Control (RBAC)
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/catalog
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_binding
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants

  Provisions top-level Unity Catalog catalogs:
    1. Creates databricks_catalog resources using dedicated prefix paths inside the shared
       Unity Catalog root S3 bucket (s3://<uc_root_bucket_name>/catalogs/<subpath>),
       avoiding the need for separate S3 buckets per catalog while preserving logical path separation.
    2. Attaches ISOLATED catalogs to designated workspaces via databricks_workspace_binding
       with configurable READ_WRITE or READ_ONLY binding modes.
    3. Applies authoritative role-based access control grants via databricks_grants.
*/

/* 1. Unity Catalog Catalogs */
resource "databricks_catalog" "this" {
  for_each = var.catalogs

  name                           = each.value.name
  comment                        = each.value.comment
  storage_root                   = "s3://${var.uc_root_bucket_name}/catalogs/${coalesce(each.value.storage_subpath, each.value.name)}"
  isolation_mode                 = coalesce(each.value.isolation_mode, "ISOLATED")
  enable_predictive_optimization = coalesce(each.value.enable_predictive_optimization, "ENABLE")
  owner                          = coalesce(each.value.owner, var.owner_group_name)
  force_destroy                  = coalesce(each.value.force_destroy, false)
  properties                     = coalesce(each.value.properties, {})
}

/* 2. Catalog-to-Workspace Attachments (Workspace Bindings) */
resource "databricks_workspace_binding" "this" {
  for_each = local.catalog_workspace_bindings

  securable_name = databricks_catalog.this[each.value.catalog_key].name
  securable_type = "catalog"
  workspace_id   = each.value.workspace_id
  binding_type   = each.value.binding_type
}

/* 3. Role-Based Access Control (RBAC) Grants per Catalog */
resource "databricks_grants" "this" {
  for_each = local.catalogs_with_grants

  catalog = databricks_catalog.this[each.key].name

  dynamic "grant" {
    for_each = each.value.grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }

  depends_on = [databricks_workspace_binding.this]
}
