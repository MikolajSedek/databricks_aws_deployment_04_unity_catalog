/*
  Local Values - Unity Catalog Schemas Module
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/locals

  Filters schemas that define at least one RBAC grant.
*/

locals {
  schemas_with_grants = {
    for schema_key, schema_val in var.schemas :
    schema_key => schema_val
    if length(coalesce(schema_val.grants, [])) > 0
  }
}
