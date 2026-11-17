<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.135.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks.mws"></a> [databricks.mws](#provider\_databricks.mws) | >= 1.135.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [databricks_metastore_assignment.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_metastore_id"></a> [metastore\_id](#input\_metastore\_id) | Unique identifier of the regional Unity Catalog metastore. | `string` | n/a | yes |
| <a name="input_workspace_ids"></a> [workspace\_ids](#input\_workspace\_ids) | Map of logical workspace keys to numeric Databricks workspace IDs to attach to the metastore. | `map(number)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_assignment_ids"></a> [assignment\_ids](#output\_assignment\_ids) | Map of workspace ID to metastore assignment ID. |
| <a name="output_metastore_id"></a> [metastore\_id](#output\_metastore\_id) | Regional Unity Catalog metastore ID, exposed after workspace assignments are complete. |
<!-- END_TF_DOCS -->
