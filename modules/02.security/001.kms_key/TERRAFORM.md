# 001.kms_key

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.66.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.66.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/kms_key) | resource |
| [aws_kms_key_policy.this](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/kms_key_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | Number of days for key deletion (must be between 7 and 30 days) | `number` | `30` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | KMS key rotation enablement | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment for TF deployment | `string` | n/a | yes |
| <a name="input_kms_key_alias"></a> [kms\_key\_alias](#input\_kms\_key\_alias) | KMS key alias | `string` | n/a | yes |
| <a name="input_kms_key_description"></a> [kms\_key\_description](#input\_kms\_key\_description) | Custom KMS key description | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_arn"></a> [kms\_arn](#output\_kms\_arn) | KMS key ARN |
<!-- END_TF_DOCS -->
