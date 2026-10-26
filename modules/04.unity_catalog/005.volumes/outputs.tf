/*
  Output Values - Unity Catalog Volumes Module
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/outputs

  Exports the map of logical volume keys to 3-level full names (<catalog>.<schema>.<volume>)
  and their shared alias (<schema>.<volume>) for downstream consumption by the Open Delta Sharing module.
*/

output "volume_full_names" {
  description = "Map of logical volume keys to 3-level Unity Catalog volume identifiers (<catalog>.<schema>.<name>) and shared_as aliases."
  value = {
    for k, v in databricks_volume.this : k => {
      full_name        = v.id
      string_shared_as = "${v.schema_name}.${v.name}"
    }
  }
}
