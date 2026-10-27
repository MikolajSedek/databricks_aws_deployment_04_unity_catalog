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
| [databricks_grants.share](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_recipient.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/recipient) | resource |
| [databricks_share.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/share) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_owner_group_name"></a> [owner\_group\_name](#input\_owner\_group\_name) | Default account-level admin group owning the Delta Sharing shares and recipients (e.g. dbx-platform-admins). | `string` | n/a | yes |
| <a name="input_recipients"></a> [recipients](#input\_recipients) | Map of Delta Sharing recipient definitions supporting Open Sharing (TOKEN) and Databricks-to-Databricks (DATABRICKS). | <pre>map(object({<br/>    name                               = string<br/>    comment                            = string<br/>    authentication_type                = optional(string, "TOKEN")<br/>    owner                              = optional(string)<br/>    sharing_code                       = optional(string)<br/>    data_recipient_global_metastore_id = optional(string)<br/>    allowed_ip_addresses               = optional(list(string), [])<br/>    properties                         = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_shares"></a> [shares](#input\_shares) | Map of Delta Sharing share definitions, objects to share, and recipient keys granted SELECT access. | <pre>map(object({<br/>    name    = string<br/>    comment = string<br/>    owner   = optional(string)<br/>    objects = optional(list(object({<br/>      name                        = optional(string)<br/>      volume_key                  = optional(string)<br/>      data_object_type            = string<br/>      comment                     = optional(string)<br/>      shared_as                   = optional(string)<br/>      string_shared_as            = optional(string)<br/>      history_data_sharing_status = optional(string)<br/>    })), [])<br/>    recipient_keys = optional(list(string), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_volume_full_names"></a> [volume\_full\_names](#input\_volume\_full\_names) | Optional map of logical volume keys to volume identifiers (full\_name, string\_shared\_as) exported by the volumes module. | <pre>map(object({<br/>    full_name        = string<br/>    string_shared_as = string<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
