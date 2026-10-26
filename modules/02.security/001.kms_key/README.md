# AWS KMS Customer Managed Key Module (`001.kms_key`)

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-623CE4?logo=terraform)](https://developer.hashicorp.com/terraform/docs)
[![AWS Provider](https://img.shields.io/badge/AWS_Provider-%3E%3D5.0-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
[![AWS KMS](https://img.shields.io/badge/AWS_Security-KMS%20CMK-FF9900?logo=amazon-aws)](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html)

---

## 1. Executive Summary

- **Purpose & Scope**:
  This module deploys a hardened, customer-managed AWS Key Management Service (KMS) key (CMK), key policy, and alias. It establishes an envelope encryption foundation used to protect sensitive infrastructure state, Terraform remote backends, and Unity Catalog S3 storage buckets (metastore root bucket and optional external volume buckets) across deployment environments.
- **Problem Statement & Solution**:
  Default AWS-managed keys (such as `aws/s3`) lack granular access control delegation, cannot be shared across external IAM roles or accounts with custom conditions, and offer limited auditability. This module solves this by creating a dedicated customer-managed key with automated annual key rotation, root account policy delegation (enabling IAM policy and KMS grant-governed access without ephemeral session drift), and deletion prevention lifecycles.
- **Key Business & Security Outcomes**:
  - **Cryptographic Independence**: Full customer ownership over cryptographic keys and envelope encryption policies.
  - **Accidental Deletion Protection**: Terraform `prevent_destroy` lifecycle guarantees safeguard against accidental key destruction.
  - **Compliance Alignment**: Automatic key rotation and configurable deletion waiting windows (7 to 30 days).

---

## 2. General Logic & Operational Flow

### 2.1 Configuration & Provisioning Lifecycle
1. **Caller Identity Discovery**: Reads current account ID using `data.aws_caller_identity.current`.
2. **KMS Key Instantiation**: Creates `aws_kms_key.this` with automatic key rotation enabled (`enable_key_rotation = true`) and a 30-day deletion waiting period.
3. **Key Policy Attachment**: Configures `aws_kms_key_policy.this` granting the AWS account principal (`arn:aws:iam::<account_id>:root`) administrative permissions (`kms:*`). This standard AWS KMS default key policy delegates authorization to IAM policies and KMS grants attached to users and assumed Unity Catalog storage credential roles in the account while avoiding perpetual plan diffs caused by dynamic STS session identifiers.
4. **Alias Creation**: Creates `aws_kms_alias.this` formatting the key name as `alias/${var.kms_key_alias}-${var.environment}`.

### 2.2 Operational Use Cases
- **Terraform Remote State**: Passed into [`001.env_backend_bucket`](../../03.storage/001.env_backend_bucket) to enforce Server-Side Encryption with KMS (SSE-KMS) on the S3 bucket and state objects.
- **Unity Catalog Root & External Storage**: Passed into [`002.uc_root_bucket`](../../03.storage/002.uc_root_bucket), [`001.metastore`](../../04.unity_catalog/001.metastore), and [`005.volumes`](../../04.unity_catalog/005.volumes) to enforce SSE-KMS on the Unity Catalog metastore root storage bucket and optional external volume storage bucket.

---

## 3. Architecture of the Module

### 3.1 Resource Architecture & Attributes

| Resource Type | Resource Identifier | Configuration Attributes | Security Role |
|:---|:---|:---|:---|
| `aws_kms_key` | `this` | `enable_key_rotation = true`<br/>`deletion_window_in_days = 30`<br/>`prevent_destroy = true` | Root cryptographic key |
| `aws_kms_key_policy` | `this` | Root account IAM policy delegation | Access control boundary |
| `aws_kms_alias` | `this` | `alias/${kms_key_alias}-${environment}` | Human-readable key reference |

---

## 4. Architecture C4 Visualisation

### 4.1 Level 2: Component Diagram

```mermaid
flowchart TD
    classDef input fill:#ECEFF1,stroke:#37474F,stroke-width:2px,color:#212121;
    classDef res fill:#FFF8E1,stroke:#F57F17,stroke-width:1.5px,color:#E65100;
    classDef out fill:#E8F5E9,stroke:#2E7D32,stroke-width:1.5px,color:#1B5E20;

    Inputs["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/general/general.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Inputs</b><br/>kms_key_alias, kms_key_description, environment"]:::input
    CallerData["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/security/identity-and-access-management-iam.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>data.aws_caller_identity.current</b>"]:::res
    KmsKey["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/security/key-management-service.png' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>aws_kms_key.this</b><br/>(enable_key_rotation: true)"]:::res
    KmsPolicy["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/security/identity-and-access-management-iam-permissions.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>aws_kms_key_policy.this</b><br/>(Root Account Delegation)"]:::res
    KmsAlias["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/security/key-management-service.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>aws_kms_alias.this</b><br/>(alias/...)"]:::res
    OutputArn["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/general/general.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Output: kms_arn</b>"]:::out

    Inputs --> KmsKey
    Inputs --> KmsAlias
    CallerData --> KmsPolicy
    KmsKey --> KmsPolicy
    KmsKey --> KmsAlias
    KmsKey --> OutputArn
```

---

## 5. All Modules Used with Short Summaries

This module does not invoke any submodules. It provisions native AWS KMS resources directly.

- **Consumers**:
  - [`001.env_backend_bucket`](../../03.storage/001.env_backend_bucket) - Uses the resulting KMS Key ARN for S3 remote state server-side encryption.
  - [`002.uc_root_bucket`](../../03.storage/002.uc_root_bucket) - Uses dedicated CMK ARNs (`uc_root_storage` and `uc_external_volumes`) for Unity Catalog S3 storage encryption.
  - [`001.metastore`](../../04.unity_catalog/001.metastore) & [`005.volumes`](../../04.unity_catalog/005.volumes) - Attach KMS grants and IAM policy permissions for Unity Catalog storage credentials.
  - [`environments/dev`](../../../environments/dev) - Root environment orchestrator instantiating this CMK module for state persistence and extra Unity Catalog KMS keys.

---

## 6. Terraform Documentation Interface

> [!NOTE]
> Machine-generated interface specifications for this module are maintained by `terraform-docs` in [`TERRAFORM.md`](./TERRAFORM.md).

### 6.1 Essential Inputs Summary

| Variable | Type | Description | Required |
|:---|:---:|:---|:---:|
| `kms_key_alias` | `string` | Base alias name for the KMS key | Yes |
| `kms_key_description` | `string` | Custom description for the KMS key | Yes |
| `environment` | `string` | Environment qualifier (e.g. `dev`) | Yes |
| `enable_key_rotation` | `bool` | Enable annual automatic key rotation (default: `true`) | No |
| `deletion_window_in_days` | `number` | Waiting period before key destruction (7-30 days, default: `30`) | No |

### 6.2 Essential Outputs Summary

| Output | Type | Description |
|:---|:---:|:---|
| `kms_arn` | `string` | The Amazon Resource Name (ARN) of the created KMS key |

---

## 7. Important Links and Resources

### 7.1 Authoritative Documentation
- [AWS KMS Developer Guide](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html) - AWS Key Management Service concepts.
- [AWS KMS Key Policies](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html) - Policy architecture and best practices.
- [Allows access to AWS account and enables IAM policies](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html) - Default key policy delegation details.
- [Terraform AWS KMS Key Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) - Provider documentation.

### 7.2 Internal References
- [Terraform Contract (`TERRAFORM.md`)](./TERRAFORM.md)
- [Remote Backend Bucket Module (`001.env_backend_bucket`)](../../03.storage/001.env_backend_bucket)
- [Unity Catalog Root Bucket Module (`002.uc_root_bucket`)](../../03.storage/002.uc_root_bucket)
- [Authoritative README Template](../../../.ai/README_TEMPLATE.md)
