<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.135.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.140.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [databricks_grants.uc_secret](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_secret.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret) | resource |
| [databricks_secret_acl.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_acl) | resource |
| [databricks_secret_scope.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_scope) | resource |
| [databricks_secret_uc.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_uc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_schema_names"></a> [schema\_names](#input\_schema\_names) | Map of logical schema keys to resolved catalog\_name, schema\_name, and full\_name. | <pre>map(object({<br/>    catalog_name = string<br/>    schema_name  = string<br/>    full_name    = string<br/>  }))</pre> | n/a | yes |
| <a name="input_secret_scopes"></a> [secret\_scopes](#input\_secret\_scopes) | Optional map of workspace-level Databricks secret scopes, keys, and ACLs. | <pre>map(object({<br/>    scope_name = string<br/>    secrets = optional(map(object({<br/>      key          = string<br/>      string_value = string<br/>    })), {})<br/>    acls = optional(list(object({<br/>      principal  = string<br/>      permission = string<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_uc_secrets"></a> [uc\_secrets](#input\_uc\_secrets) | Map of Unity Catalog secrets (databricks\_secret\_uc) scoped to schemas with RBAC grants. | <pre>map(object({<br/>    schema_key  = string<br/>    name        = string<br/>    value       = string<br/>    comment     = string<br/>    owner       = optional(string)<br/>    expire_time = optional(string)<br/>    grants = optional(list(object({<br/>      principal  = string<br/>      privileges = list(string)<br/>    })), [])<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
