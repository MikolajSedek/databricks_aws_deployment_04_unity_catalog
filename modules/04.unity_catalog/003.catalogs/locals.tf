/*
  Local Values - Unity Catalog Catalogs Module
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/locals

  Filters catalogs by isolation mode and RBAC grants, and flattens workspace
  bindings into structured intermediate locals to minimize cognitive complexity
  for resource iteration.
*/

locals {
  /* 1. Filter catalogs configured with ISOLATED mode (workspace bindings apply only to isolated catalogs) */
  isolated_catalogs = {
    for cat_key, cat in var.catalogs :
    cat_key => cat
    if coalesce(cat.isolation_mode, "ISOLATED") == "ISOLATED"
  }

  /* 2. Intermediate list: Flatten workspace bindings across isolated catalogs into a linear list */
  raw_catalog_workspace_bindings = flatten([
    for cat_key, cat in local.isolated_catalogs : [
      for binding in coalesce(cat.workspace_bindings, []) : {
        catalog_key  = cat_key
        workspace_id = binding.workspace_id
        binding_type = coalesce(binding.binding_type, "BINDING_TYPE_READ_WRITE")
      }
    ]
  ])

  /* 3. Final map: Index workspace bindings by unique binding key for databricks_workspace_binding */
  catalog_workspace_bindings = {
    for binding in local.raw_catalog_workspace_bindings :
    "${binding.catalog_key}__${binding.workspace_id}" => {
      catalog_key  = binding.catalog_key
      workspace_id = binding.workspace_id
      binding_type = binding.binding_type
    }
  }

  /* 4. Filter catalogs that define at least one RBAC grant */
  catalogs_with_grants = {
    for cat_key, cat in var.catalogs :
    cat_key => cat
    if length(coalesce(cat.grants, [])) > 0
  }
}
