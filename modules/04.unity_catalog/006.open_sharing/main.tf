/*
  Unity Catalog Open Delta Sharing (Shares, Recipients, and Share Grants)
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/share
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/recipient
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants

  Configures basic Open Delta Sharing in Unity Catalog:
    1. databricks_share: Registers read-only collections of schemas, tables, or volumes.
    2. databricks_recipient: Creates external Open Sharing recipients (authentication_type = "TOKEN")
       with optional CIDR IP allowlists and custom recipient properties.
    3. databricks_grants: Grants SELECT privileges on shares to designated recipients.
*/

/* 1. Delta Sharing Shares */
resource "databricks_share" "this" {
  for_each = var.shares

  name    = each.value.name
  comment = each.value.comment
  owner   = coalesce(each.value.owner, var.owner_group_name)

  dynamic "object" {
    for_each = coalesce(each.value.objects, [])
    content {
      name                        = object.value.volume_key != null ? var.volume_full_names[object.value.volume_key].full_name : object.value.name
      data_object_type            = object.value.data_object_type
      comment                     = object.value.comment
      shared_as                   = object.value.shared_as
      string_shared_as            = object.value.volume_key != null ? var.volume_full_names[object.value.volume_key].string_shared_as : object.value.string_shared_as
      history_data_sharing_status = object.value.history_data_sharing_status
    }
  }
}

/* 2. Delta Sharing Recipients (Open Sharing TOKEN or DATABRICKS) */
resource "databricks_recipient" "this" {
  for_each = var.recipients

  name                               = each.value.name
  comment                            = each.value.comment
  authentication_type                = coalesce(each.value.authentication_type, "TOKEN")
  owner                              = coalesce(each.value.owner, var.owner_group_name)
  sharing_code                       = each.value.sharing_code
  data_recipient_global_metastore_id = each.value.data_recipient_global_metastore_id

  dynamic "ip_access_list" {
    for_each = length(coalesce(each.value.allowed_ip_addresses, [])) > 0 ? [1] : []
    content {
      allowed_ip_addresses = each.value.allowed_ip_addresses
    }
  }

  dynamic "properties_kvpairs" {
    for_each = length(coalesce(each.value.properties, {})) > 0 ? [1] : []
    content {
      properties = each.value.properties
    }
  }
}

/* 3. Share SELECT Grants to Recipients */
resource "databricks_grants" "share" {
  for_each = local.shares_with_recipients

  share = databricks_share.this[each.key].name

  dynamic "grant" {
    for_each = each.value.recipient_keys
    content {
      principal  = databricks_recipient.this[grant.value].name
      privileges = ["SELECT"]
    }
  }
}
