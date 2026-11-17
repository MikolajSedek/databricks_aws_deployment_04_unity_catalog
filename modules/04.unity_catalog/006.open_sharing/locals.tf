/*
  Local Values - Basic Open Delta Sharing Module
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/locals

  Filters shares that have at least one recipient assigned for SELECT grants.
*/

locals {
  shares_with_recipients = {
    for k, v in var.shares :
    k => v
    if length(coalesce(v.recipient_keys, [])) > 0
  }
}
