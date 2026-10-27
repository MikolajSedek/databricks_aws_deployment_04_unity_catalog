/*
  Output Values - Unity Catalog Catalogs Module
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/outputs

  Exports the map of logical catalog keys to resolved catalog names for
  downstream schema, volume, secret, and Delta Sharing modules.
*/

output "catalog_names" {
  description = "Map of logical catalog keys to provisioned Unity Catalog names."
  value       = { for k, v in databricks_catalog.this : k => v.name }

  depends_on = [
    databricks_workspace_binding.this,
    databricks_grants.this
  ]
}
