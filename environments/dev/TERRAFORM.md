<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.66.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | 1.135.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks.mws"></a> [databricks.mws](#provider\_databricks.mws) | 1.135.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backend_bucket"></a> [backend\_bucket](#module\_backend\_bucket) | ../../modules/03.storage/001.env_backend_bucket | n/a |
| <a name="module_catalogs"></a> [catalogs](#module\_catalogs) | ../../modules/04.unity_catalog/003.catalogs | n/a |
| <a name="module_extra_kms_keys"></a> [extra\_kms\_keys](#module\_extra\_kms\_keys) | ../../modules/02.security/001.kms_key | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | ../../modules/02.security/001.kms_key | n/a |
| <a name="module_metastore"></a> [metastore](#module\_metastore) | ../../modules/04.unity_catalog/001.metastore | n/a |
| <a name="module_metastore_assignment"></a> [metastore\_assignment](#module\_metastore\_assignment) | ../../modules/04.unity_catalog/002.metastore_assignment | n/a |
| <a name="module_open_sharing"></a> [open\_sharing](#module\_open\_sharing) | ../../modules/04.unity_catalog/006.open_sharing | n/a |
| <a name="module_schemas"></a> [schemas](#module\_schemas) | ../../modules/04.unity_catalog/004.schemas | n/a |
| <a name="module_uc_external_volumes_bucket"></a> [uc\_external\_volumes\_bucket](#module\_uc\_external\_volumes\_bucket) | ../../modules/03.storage/002.uc_root_bucket | n/a |
| <a name="module_uc_root_bucket"></a> [uc\_root\_bucket](#module\_uc\_root\_bucket) | ../../modules/03.storage/002.uc_root_bucket | n/a |
| <a name="module_uc_secrets"></a> [uc\_secrets](#module\_uc\_secrets) | ../../modules/02.security/002.uc_secrets | n/a |
| <a name="module_volumes"></a> [volumes](#module\_volumes) | ../../modules/04.unity_catalog/005.volumes | n/a |

## Resources

| Name | Type |
|------|------|
| [databricks_group_member.deployer_admin](https://registry.terraform.io/providers/databricks/databricks/1.135.0/docs/resources/group_member) | resource |
| [databricks_current_user.data_engineering](https://registry.terraform.io/providers/databricks/databricks/1.135.0/docs/data-sources/current_user) | data source |
| [databricks_group.data_analysts](https://registry.terraform.io/providers/databricks/databricks/1.135.0/docs/data-sources/group) | data source |
| [databricks_group.data_engineers](https://registry.terraform.io/providers/databricks/databricks/1.135.0/docs/data-sources/group) | data source |
| [databricks_group.data_scientists](https://registry.terraform.io/providers/databricks/databricks/1.135.0/docs/data-sources/group) | data source |
| [databricks_group.platform_admins](https://registry.terraform.io/providers/databricks/databricks/1.135.0/docs/data-sources/group) | data source |
| [databricks_mws_workspaces.all](https://registry.terraform.io/providers/databricks/databricks/1.135.0/docs/data-sources/mws_workspaces) | data source |
| [databricks_service_principal.deployer](https://registry.terraform.io/providers/databricks/databricks/1.135.0/docs/data-sources/service_principal) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | The allowed AWS Account ID to prevent accidental deployment to the wrong account. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region where resources will be deployed. | `string` | `"eu-central-1"` | no |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | The Databricks account ID (UUID) used by the account-level provider. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment name (e.g. dev, staging, prod). | `string` | `"dev"` | no |
| <a name="input_governance_workspace_url"></a> [governance\_workspace\_url](#input\_governance\_workspace\_url) | Optional override for the workspace URL of the primary Databricks workspace (Data Engineering). When null, dynamically resolved via data.databricks\_current\_user. | `string` | `null` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | AWS CLI user profile | `string` | `"default"` | no |
| <a name="input_service_principal_id"></a> [service\_principal\_id](#input\_service\_principal\_id) | The service principal ID for the Databricks workspace / account | `string` | n/a | yes |
| <a name="input_service_principal_secret"></a> [service\_principal\_secret](#input\_service\_principal\_secret) | The service principal secret for the Databricks workspace / account | `string` | n/a | yes |
| <a name="input_uc_external_api_key_secret"></a> [uc\_external\_api\_key\_secret](#input\_uc\_external\_api\_key\_secret) | Sensitive secret value stored in Unity Catalog secret (shared\_enterprise\_dev.security\_vault.external\_ingestion\_api\_key). | `string` | `"placeholder-uc-external-ingestion-api-key-change-me"` | no |
| <a name="input_uc_jdbc_password_secret"></a> [uc\_jdbc\_password\_secret](#input\_uc\_jdbc\_password\_secret) | Sensitive secret value stored in Unity Catalog secret (data\_engineering\_dev.raw\_ingestion.erp\_jdbc\_password). | `string` | `"placeholder-uc-erp-jdbc-password-change-me"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
