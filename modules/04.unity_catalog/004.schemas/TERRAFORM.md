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
| [databricks_grants.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_schema.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/schema) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_catalog_names"></a> [catalog\_names](#input\_catalog\_names) | Map of logical catalog keys to resolved Unity Catalog names. | `map(string)` | n/a | yes |
| <a name="input_owner_group_name"></a> [owner\_group\_name](#input\_owner\_group\_name) | Default account-level admin group owning the schemas (e.g. dbx-platform-admins). | `string` | n/a | yes |
| <a name="input_schemas"></a> [schemas](#input\_schemas) | Map of schema definitions keyed by logical identifier, including parent catalog\_key and RBAC grants. | <pre>map(object({<br/>    catalog_key                    = string<br/>    name                           = string<br/>    comment                        = string<br/>    owner                          = optional(string)<br/>    enable_predictive_optimization = optional(string, "INHERIT")<br/>    force_destroy                  = optional(bool, false)<br/>    properties                     = optional(map(string), {})<br/>    grants = optional(list(object({<br/>      principal  = string<br/>      privileges = list(string)<br/>    })), [])<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_schema_names"></a> [schema\_names](#output\_schema\_names) | Map of logical schema keys to resolved catalog\_name, schema\_name, and full\_name (id). |
<!-- END_TF_DOCS -->
