/*
  Unity Catalog Schemas (Databases) and Role-Based Access Control (RBAC)
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/schema
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants

  Provisions second-level namespace schemas within Unity Catalog catalogs and
  attaches authoritative RBAC grants per schema.
*/

/* 1. Unity Catalog Schemas */
resource "databricks_schema" "this" {
  for_each = var.schemas

  catalog_name                   = var.catalog_names[each.value.catalog_key]
  name                           = each.value.name
  comment                        = each.value.comment
  owner                          = coalesce(each.value.owner, var.owner_group_name)
  enable_predictive_optimization = coalesce(each.value.enable_predictive_optimization, "INHERIT")
  force_destroy                  = coalesce(each.value.force_destroy, false)
  properties                     = coalesce(each.value.properties, {})
}

/* 2. Schema Role-Based Access Control (RBAC) Grants */
resource "databricks_grants" "this" {
  for_each = local.schemas_with_grants

  schema = databricks_schema.this[each.key].id

  dynamic "grant" {
    for_each = each.value.grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}
