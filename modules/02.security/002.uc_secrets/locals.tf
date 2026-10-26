/*
  Local Values - Unity Catalog Secrets Module
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/locals

  Filters Unity Catalog secrets with active RBAC grants and flattens optional
  workspace secret scopes and ACLs. Employs sha256() hashing on nonsensitive
  keys to avoid secret exposition and prevent sensitive taint propagation.
*/

locals {
  uc_secrets_with_grants = {
    for k, v in var.uc_secrets :
    k => v
    if length(coalesce(v.grants, [])) > 0
  }

  workspace_secrets = nonsensitive(merge([
    for scope_key, scope in var.secret_scopes : {
      for sec_key, sec in coalesce(scope.secrets, {}) :
      sha256(nonsensitive("${scope_key}/${sec.key}")) => {
        scope_key = scope_key
        sec_key   = sec_key
        key       = sec.key
      }
    }
  ]...))

  workspace_secret_acls = nonsensitive(merge([
    for scope_key, scope in var.secret_scopes : {
      for acl in coalesce(scope.acls, []) :
      sha256(nonsensitive("${scope_key}/${acl.principal}")) => {
        scope_key  = scope_key
        principal  = acl.principal
        permission = acl.permission
      }
    }
  ]...))
}
