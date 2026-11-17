/*
  Local Values - Unity Catalog Secrets Module
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/locals

  Filters Unity Catalog secrets with active RBAC grants and flattens optional
  workspace secret scopes and ACLs. Deconstructs complex nested iterations into
  discrete intermediate list and map locals to minimize cognitive complexity,
  while employing sha256() hashing on nonsensitive keys to prevent sensitive
  taint propagation during resource for_each iteration.
*/

locals {
  /* 1. Unity Catalog secrets with active RBAC grants */
  uc_secrets_with_grants = {
    for k, v in var.uc_secrets :
    k => v
    if length(coalesce(v.grants, [])) > 0
  }

  /* 2. Intermediate list: Flatten nested secret definitions across all scopes */
  raw_workspace_secrets = flatten([
    for scope_key, scope in var.secret_scopes : [
      for sec_key, sec in coalesce(scope.secrets, {}) : {
        scope_key = scope_key
        sec_key   = sec_key
        key       = sec.key
      }
    ]
  ])

  /* 3. Final map: Index workspace secrets by non-sensitive SHA-256 hash for for_each */
  workspace_secrets = nonsensitive({
    for secret in local.raw_workspace_secrets :
    sha256(nonsensitive("${secret.scope_key}/${secret.key}")) => {
      scope_key = secret.scope_key
      sec_key   = secret.sec_key
      key       = secret.key
    }
  })

  /* 4. Intermediate list: Flatten nested ACL definitions across all scopes */
  raw_workspace_secret_acls = flatten([
    for scope_key, scope in var.secret_scopes : [
      for acl in coalesce(scope.acls, []) : {
        scope_key  = scope_key
        principal  = acl.principal
        permission = acl.permission
      }
    ]
  ])

  /* 5. Final map: Index workspace secret ACLs by non-sensitive SHA-256 hash for for_each */
  workspace_secret_acls = nonsensitive({
    for acl in local.raw_workspace_secret_acls :
    sha256(nonsensitive("${acl.scope_key}/${acl.principal}")) => {
      scope_key  = acl.scope_key
      principal  = acl.principal
      permission = acl.permission
    }
  })
}
