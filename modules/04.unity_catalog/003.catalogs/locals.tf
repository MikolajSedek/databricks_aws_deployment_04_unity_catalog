/*
  Local Values - Unity Catalog Catalogs Module
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/locals

  Flattens catalog workspace bindings and filters catalogs with active RBAC grants.
*/

locals {
  /* Flatten workspace bindings across all ISOLATED catalogs */
  catalog_workspace_bindings = merge([
    for cat_key, cat in var.catalogs : {
      for binding in coalesce(cat.workspace_bindings, []) :
      "${cat_key}__${binding.workspace_id}" => {
        catalog_key  = cat_key
        workspace_id = binding.workspace_id
        binding_type = coalesce(binding.binding_type, "BINDING_TYPE_READ_WRITE")
      }
    }
    if coalesce(cat.isolation_mode, "ISOLATED") == "ISOLATED"
  ]...)

  /* Filter catalogs that define at least one RBAC grant */
  catalogs_with_grants = {
    for cat_key, cat in var.catalogs :
    cat_key => cat
    if length(coalesce(cat.grants, [])) > 0
  }
}
