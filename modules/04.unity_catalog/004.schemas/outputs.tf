/*
  Output Values - Unity Catalog Schemas Module
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/outputs

  Exports the map of logical schema keys to resolved schema metadata for
  downstream volume, UC secret, and Delta Sharing modules.
*/

output "schema_names" {
  description = "Map of logical schema keys to resolved catalog_name, schema_name, and full_name (id)."
  value = {
    for k, v in databricks_schema.this : k => {
      catalog_name = v.catalog_name
      schema_name  = v.name
      full_name    = v.id
    }
  }
}
