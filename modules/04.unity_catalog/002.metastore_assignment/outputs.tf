/*
  Unity Catalog Metastore Assignment Outputs
*/

output "metastore_id" {
  description = "Regional Unity Catalog metastore ID, exposed after workspace assignments are complete."
  value       = var.metastore_id
  depends_on  = [databricks_metastore_assignment.this]
}

output "assignment_ids" {
  description = "Map of workspace ID to metastore assignment ID."
  value       = { for k, v in databricks_metastore_assignment.this : k => v.id }
}
