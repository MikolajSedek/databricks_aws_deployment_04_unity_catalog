<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.135.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_databricks.mws"></a> [databricks.mws](#provider\_databricks.mws) | >= 1.135.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.metastore_data_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.metastore_data_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.metastore_data_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_grant.metastore_data_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_grant) | resource |
| [databricks_metastore.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore) | resource |
| [databricks_metastore_data_access.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_data_access) | resource |
| [time_sleep.wait_for_iam_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [databricks_aws_unity_catalog_assume_role_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_unity_catalog_assume_role_policy) | data source |
| [databricks_aws_unity_catalog_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_unity_catalog_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | 12-digit AWS Account ID hosting the Unity Catalog S3 bucket and IAM role. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where the Unity Catalog metastore is deployed. | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the S3 root storage bucket for the Unity Catalog metastore. | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks Account ID (UUID) used as external\_id in the Unity Catalog IAM trust policy. | `string` | n/a | yes |
| <a name="input_delta_sharing_organization_name"></a> [delta\_sharing\_organization\_name](#input\_delta\_sharing\_organization\_name) | Organization display name used for Delta Sharing metadata. | `string` | `null` | no |
| <a name="input_delta_sharing_recipient_token_lifetime_in_seconds"></a> [delta\_sharing\_recipient\_token\_lifetime\_in\_seconds](#input\_delta\_sharing\_recipient\_token\_lifetime\_in\_seconds) | Expiration duration in seconds for Delta Sharing recipient access tokens (default: 2592000 = 30 days). | `number` | `2592000` | no |
| <a name="input_delta_sharing_scope"></a> [delta\_sharing\_scope](#input\_delta\_sharing\_scope) | Delta Sharing scope on the metastore (INTERNAL or INTERNAL\_AND\_EXTERNAL). | `string` | `"INTERNAL_AND_EXTERNAL"` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Whether to destroy the metastore regardless of its contents. | `bool` | `false` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the AWS IAM role assumed by Databricks Unity Catalog for metastore storage access. | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Customer-managed KMS key ARN encrypting the Unity Catalog S3 root bucket. | `string` | n/a | yes |
| <a name="input_metastore_name"></a> [metastore\_name](#input\_metastore\_name) | Name of the Unity Catalog metastore (one metastore per AWS region per account). | `string` | n/a | yes |
| <a name="input_owner_group_name"></a> [owner\_group\_name](#input\_owner\_group\_name) | Account-level group display name assigned as owner of the Unity Catalog metastore (e.g. dbx-platform-admins). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags to apply to the AWS IAM role and policy. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_metastore_id"></a> [metastore\_id](#output\_metastore\_id) | Unique identifier of the provisioned Unity Catalog metastore. |
<!-- END_TF_DOCS -->
