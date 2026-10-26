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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.70.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.140.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.14.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_grant.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_grant) | resource |
| [databricks_external_location.external](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/external_location) | resource |
| [databricks_grants.external_location](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_grants.volume](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_storage_credential.external](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/storage_credential) | resource |
| [databricks_volume.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/volume) | resource |
| [time_sleep.wait_for_external_iam](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [databricks_aws_unity_catalog_assume_role_policy.external](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_unity_catalog_assume_role_policy) | data source |
| [databricks_aws_unity_catalog_policy.external](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_unity_catalog_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | 12-digit AWS Account ID used when provisioning optional external storage credentials. | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks Account ID (UUID) used as external\_id in the Unity Catalog IAM trust policy. | `string` | n/a | yes |
| <a name="input_external_locations"></a> [external\_locations](#input\_external\_locations) | Optional map of external storage locations (IAM role, S3 bucket, KMS key, URL prefix, and grants) for EXTERNAL volumes. | <pre>map(object({<br/>    name           = string<br/>    bucket_name    = string<br/>    kms_key_arn    = string<br/>    iam_role_name  = string<br/>    s3_subpath     = optional(string, "external-volumes")<br/>    comment        = optional(string, "External S3 location for Unity Catalog volumes")<br/>    isolation_mode = optional(string, "ISOLATION_MODE_OPEN")<br/>    read_only      = optional(bool, false)<br/>    force_destroy  = optional(bool, false)<br/>    grants = optional(list(object({<br/>      principal  = string<br/>      privileges = list(string)<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_owner_group_name"></a> [owner\_group\_name](#input\_owner\_group\_name) | Default account-level admin group owning the volumes and external locations (e.g. dbx-platform-admins). | `string` | n/a | yes |
| <a name="input_schema_names"></a> [schema\_names](#input\_schema\_names) | Map of logical schema keys to resolved catalog\_name, schema\_name, and full\_name. | <pre>map(object({<br/>    catalog_name = string<br/>    schema_name  = string<br/>    full_name    = string<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional AWS tags for optional external location IAM roles and policies. | `map(string)` | `{}` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Map of Unity Catalog volume definitions supporting MANAGED and optional EXTERNAL volume types with RBAC grants. | <pre>map(object({<br/>    schema_key            = string<br/>    name                  = string<br/>    volume_type           = optional(string, "MANAGED")<br/>    comment               = string<br/>    owner                 = optional(string)<br/>    external_location_key = optional(string)<br/>    external_subpath      = optional(string)<br/>    grants = optional(list(object({<br/>      principal  = string<br/>      privileges = list(string)<br/>    })), [])<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_volume_full_names"></a> [volume\_full\_names](#output\_volume\_full\_names) | Map of logical volume keys to 3-level Unity Catalog volume identifiers (<catalog>.<schema>.<name>) and shared\_as aliases. |
<!-- END_TF_DOCS -->
