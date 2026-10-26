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
| [databricks_catalog.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/catalog) | resource |
| [databricks_grants.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_workspace_binding.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_binding) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_catalogs"></a> [catalogs](#input\_catalogs) | Map of catalog definitions including isolation mode, workspace bindings, and RBAC grants. | <pre>map(object({<br/>    name                           = string<br/>    comment                        = string<br/>    isolation_mode                 = optional(string, "ISOLATED")<br/>    enable_predictive_optimization = optional(string, "ENABLE")<br/>    force_destroy                  = optional(bool, false)<br/>    owner                          = optional(string)<br/>    storage_subpath                = optional(string)<br/>    properties                     = optional(map(string), {})<br/>    workspace_bindings = optional(list(object({<br/>      workspace_id = number<br/>      binding_type = optional(string, "BINDING_TYPE_READ_WRITE")<br/>    })), [])<br/>    grants = optional(list(object({<br/>      principal  = string<br/>      privileges = list(string)<br/>    })), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_owner_group_name"></a> [owner\_group\_name](#input\_owner\_group\_name) | Default account-level admin group owning the catalogs (e.g. dbx-platform-admins). | `string` | n/a | yes |
| <a name="input_uc_root_bucket_name"></a> [uc\_root\_bucket\_name](#input\_uc\_root\_bucket\_name) | Name of the shared Unity Catalog root S3 bucket where catalog managed prefixes reside. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_catalog_names"></a> [catalog\_names](#output\_catalog\_names) | Map of logical catalog keys to provisioned Unity Catalog names. |
<!-- END_TF_DOCS -->
