/*
  Local Values - Unity Catalog Volumes Module
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/locals

  Filters external locations and volumes with active RBAC grants.
*/

locals {
  external_locations_with_grants = {
    for k, v in var.external_locations :
    k => v
    if length(coalesce(v.grants, [])) > 0
  }

  volumes_with_grants = {
    for k, v in var.volumes :
    k => v
    if length(coalesce(v.grants, [])) > 0
  }
}
