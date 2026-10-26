/*
  Unity Catalog Secrets (databricks_secret_uc) and Optional Workspace Secret Scopes
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_uc
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_scope
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_acl

  Manages governed secrets in Unity Catalog and optional workspace secret scopes:
    1. Native Unity Catalog Secrets (databricks_secret_uc): Stores sensitive credentials
       inside 3-level namespace schemas (<catalog>.<schema>.<secret_name>) and governs
       read/manage permissions via databricks_grants (READ_SECRET, MANAGE).
    2. Optional Workspace Secret Scopes (databricks_secret_scope, databricks_secret,
       databricks_secret_acl): Supports Spark configuration references ({{secrets/scope/key}}).
*/

/* 1. Native Unity Catalog Secrets (3-Level Namespace Objects) */
resource "databricks_secret_uc" "this" {
  for_each = var.uc_secrets

  catalog_name = var.schema_names[each.value.schema_key].catalog_name
  schema_name  = var.schema_names[each.value.schema_key].schema_name
  name         = each.value.name
  value        = each.value.value
  comment      = each.value.comment
  owner        = coalesce(each.value.owner, var.owner_group_name)
  expire_time  = each.value.expire_time
}

/* 2. Role-Based Access Control (RBAC) Grants for Unity Catalog Secrets */
resource "databricks_grants" "uc_secret" {
  for_each = local.uc_secrets_with_grants

  secret = databricks_secret_uc.this[each.key].full_name

  dynamic "grant" {
    for_each = each.value.grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}

/* 3. Optional Workspace-Level Secret Scopes */
resource "databricks_secret_scope" "this" {
  for_each = var.secret_scopes

  name = each.value.scope_name
}

resource "databricks_secret" "this" {
  for_each = local.workspace_secrets

  scope        = databricks_secret_scope.this[each.value.scope_key].name
  key          = each.value.key
  string_value = var.secret_scopes[each.value.scope_key].secrets[each.value.sec_key].string_value
}

resource "databricks_secret_acl" "this" {
  for_each = local.workspace_secret_acls

  scope      = databricks_secret_scope.this[each.value.scope_key].name
  principal  = each.value.principal
  permission = each.value.permission
}
