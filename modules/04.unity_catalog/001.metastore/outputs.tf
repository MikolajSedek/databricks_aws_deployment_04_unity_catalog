/*
  Output Values - Unity Catalog Metastore Module
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/outputs

  Exports the metastore identifier for downstream workspace assignment consumption.
*/

output "metastore_id" {
  description = "Unique identifier of the provisioned Unity Catalog metastore."
  value       = databricks_metastore.this.id
}
