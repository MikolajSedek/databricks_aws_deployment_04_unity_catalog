# Dev Environment — Databricks Unity Catalog Governance (`environments/dev`)

[![Terraform](https://img.shields.io/badge/Terraform-1.16.3-623CE4?logo=terraform)](https://developer.hashicorp.com/terraform/docs)
[![AWS Provider](https://img.shields.io/badge/AWS_Provider-6.66.0-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
[![Databricks Provider](https://img.shields.io/badge/Databricks_Provider-1.135.0-FF3621?logo=databricks)](https://registry.terraform.io/providers/databricks/databricks/latest/docs)
[![Unity Catalog](https://img.shields.io/badge/Databricks-Unity_Catalog_Governance-FF3621?logo=databricks)](https://docs.databricks.com/aws/en/data-governance/unity-catalog/)

---

## 1. Executive Summary

- **Purpose & Scope**:
  This directory (`environments/dev`) is the root Terraform orchestration environment for deploying and governing **Databricks Unity Catalog** in the `dev` environment (`eu-central-1`). It unifies AWS cryptographic keys, hardened S3 storage buckets, the regional Unity Catalog metastore, multi-workspace assignments, domain-isolated and shared catalogs, medallion schemas, managed and external volumes, native Unity Catalog secrets, and Open Delta Sharing in a single declarative state.
- **Problem Statement & Solution**:
  Enterprise lakehouse deployments with multiple workspaces (`data_engineering`, `data_science`, `business_analytics`) require centralized metadata governance without proliferating S3 buckets per catalog or compute clusters per governance run. This environment solves this by:
  1. Discovering the 3 existing workspaces from `03_workspaces_and_compute_management` dynamically via `data.databricks_mws_workspaces.all` and binding them to a single regional metastore (`msedek-dbx-dep-uc-metastore-eu-central-1-dev`).
  2. Using a single shared Unity Catalog root S3 bucket (`msedek-dbx-dep-uc-metastore-root-dev`) with per-catalog S3 prefix roots (`s3://<bucket>/catalogs/<domain>`), plus a dedicated non-overlapping external volumes bucket (`msedek-dbx-dep-uc-ext-volumes-dev`).
  3. Executing all workspace-scoped Unity Catalog governance operations through the primary governance workspace (`https://dbc-273d0704-3b96.cloud.databricks.com`) with **zero extra compute clusters provisioned**.
- **Key Business & Security Outcomes**:
  - **End-to-End 3-Level Namespace Governance**: Governs Catalogs $\rightarrow$ Schemas $\rightarrow$ Volumes & Secrets under account-level SCIM groups (`dbx-platform-admins`, `dbx-data-engineers`, `dbx-data-scientists`, `dbx-data-analysts`).
  - **Workspace Isolation & Cross-Domain Sharing**: Enforces `ISOLATED` workspace bindings (`READ_WRITE` / `READ_ONLY`) on domain catalogs (`data_engineering_dev`, `data_science_dev`, `business_analytics_dev`) and `OPEN` access on `shared_enterprise_dev`.
  - **Customer-Managed KMS Envelope Encryption**: Separate KMS CMKs protect the Terraform backend state (`kms_key`), the UC root bucket (`extra_kms_keys["uc_root_storage"]`), and the external volumes bucket (`extra_kms_keys["uc_external_volumes"]`).
  - **Open Delta Sharing Ready**: Publishes live schemas and volumes to external token-authenticated recipients (`TOKEN`).

---

## 2. General Logic & Operational Flow

### 2.1 Configuration & Provisioning Lifecycle
1. **Dynamic Workspace Discovery (`data.tf` & `locals.tf`)**: Queries `data.databricks_mws_workspaces.all` (using `provider = databricks.mws`) to resolve workspace names (`msedek-dbx-dep-data-eng-dev`, `msedek-dbx-dep-data-science-dev`, `msedek-dbx-dep-data-analytics-dev`) to numeric workspace IDs (`local.workspace_ids`).
2. **State & Cryptographic Foundation**:
   - `module.kms_key` & `module.backend_bucket`: Retain the existing KMS CMK and S3 remote state bucket (`msedek-dbx-dep-unity-catalog-s3-backend-dev`).
   - `module.extra_kms_keys`: Provisions dedicated CMKs for `uc_root_storage` and `uc_external_volumes`.
3. **S3 Storage Layer**:
   - `module.uc_root_bucket`: Provisions `msedek-dbx-dep-uc-metastore-root-dev` (shared by the metastore and all catalog `storage_root` prefixes).
   - `module.uc_external_volumes_bucket`: Provisions `msedek-dbx-dep-uc-ext-volumes-dev` (dedicated to `EXTERNAL` volumes to respect the Unity Catalog non-overlapping path rule).
4. **Account-Level Metastore & Workspace Binding**:
   - `module.metastore`: Provisions the IAM role, S3/KMS policy, KMS grant, 30s STS propagation sleep, `databricks_metastore`, and `databricks_metastore_data_access`.
   - `module.metastore_assignment`: Assigns the metastore to all 3 regional workspaces.
5. **Workspace-Level 3-Level Namespace & Sharing**:
   - `module.catalogs` $\rightarrow$ `module.schemas` $\rightarrow$ `module.volumes`, `module.uc_secrets`, and `module.open_sharing`.

### 2.2 Data & Governance Plane Flow
- **Account Control Plane (`databricks.mws`)**: Authenticates to `https://accounts.cloud.databricks.com` to manage the regional metastore and workspace assignments.
- **Workspace Control Plane (`databricks.workspace`)**: Authenticates to `local.governance_workspace_url` (dynamically discovered via `data.databricks_current_user.data_engineering.workspace_url` with optional override via `var.governance_workspace_url`) to provision catalogs, workspace bindings, schemas, volumes, UC secrets, shares, recipients, and RBAC grants.

---

## 3. Architecture of the Environment

### 3.1 Catalogs, Workspace Bindings & Storage Topology

| Catalog Name | Isolation Mode | Storage Root Prefix (Shared UC Root Bucket) | Bound Workspaces (`READ_WRITE` / `READ_ONLY`) | Schemas Provisioned |
|:---|:---:|:---|:---|:---|
| `data_engineering_dev` | `ISOLATED` | `s3://msedek-dbx-dep-uc-metastore-root-dev/catalogs/data_engineering` | DE (`RW`), DS (`RO`), BA (`RO`) | `raw_ingestion`, `curated_silver` |
| `data_science_dev` | `ISOLATED` | `s3://msedek-dbx-dep-uc-metastore-root-dev/catalogs/data_science` | DS (`RW`), DE (`RO`) | `feature_store`, `model_artifacts` |
| `business_analytics_dev` | `ISOLATED` | `s3://msedek-dbx-dep-uc-metastore-root-dev/catalogs/business_analytics` | BA (`RW`), DE (`RW`) | `reporting_gold` |
| `shared_enterprise_dev` | `OPEN` | `s3://msedek-dbx-dep-uc-metastore-root-dev/catalogs/shared_enterprise` | All Attached Workspaces (`OPEN`) | `security_vault`, `open_sharing_outbox` |

### 3.2 Volumes, Secrets & Open Sharing Inventory

| Category | Object Identifier | Type / Scope | Backing Location / Target | Authorized Principals |
|:---|:---|:---:|:---|:---|
| **Volume** | `data_engineering_dev.raw_ingestion.autoloader_landing_zone` | `MANAGED` | Shared UC Root Bucket | `dbx-data-engineers` (RW) |
| **Volume** | `data_engineering_dev.raw_ingestion.partner_external_drop` | `EXTERNAL` | `s3://msedek-dbx-dep-uc-ext-volumes-dev/external-volumes/partner-drop` | `dbx-data-engineers` (RW) |
| **Volume** | `data_science_dev.model_artifacts.training_checkpoints` | `MANAGED` | Shared UC Root Bucket | `dbx-data-scientists` (RW), `dbx-data-engineers` (RO) |
| **Volume** | `business_analytics_dev.reporting_gold.executive_report_exports` | `MANAGED` | Shared UC Root Bucket | `dbx-data-analysts` (RW), `dbx-data-engineers` (RW) |
| **Volume** | `shared_enterprise_dev.open_sharing_outbox.shared_data_files` | `MANAGED` | Shared UC Root Bucket | `dbx-data-engineers` (RW), `dbx-data-analysts` (RO) + Delta Share |
| **UC Secret** | `shared_enterprise_dev.security_vault.external_ingestion_api_key` | `databricks_secret_uc` | Unity Catalog Metastore | `dbx-data-engineers` (`READ_SECRET`), `dbx-data-scientists` (`READ_SECRET`) |
| **UC Secret** | `data_engineering_dev.raw_ingestion.erp_jdbc_password` | `databricks_secret_uc` | Unity Catalog Metastore | `dbx-data-engineers` (`READ_SECRET`) |
| **Delta Share** | `enterprise_open_partner_share_dev` | `databricks_share` | Shares `open_sharing_outbox` (`SCHEMA`) + `shared_data_files` (`VOLUME`) | `external_b2b_analytics_partner_dev` (`TOKEN` recipient) |

---

## 4. Architecture C4 Visualisation

### 4.1 Level 1: System Context Diagram

```mermaid
flowchart TD
    classDef actor fill:#232F3E,stroke:#FF9900,stroke-width:2px,color:#FFFFFF;
    classDef system fill:#1E88E5,stroke:#0D47A1,stroke-width:2px,color:#FFFFFF;
    classDef external fill:#546E7A,stroke:#263238,stroke-width:2px,color:#FFFFFF;

    PlatformAdmin["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/general/users.png' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Account & Persona Groups</b><br/>(Admins, DE, DS, BA)"]:::actor
    ExternalPartner["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/general/user.png' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>External B2B Partner</b><br/>(Open Delta Sharing TOKEN)"]:::actor
    DatabricksCP["<img src='https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/unity-catalog.png' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Databricks Control Plane</b><br/>(Account MWS + 3 E2 Workspaces)"]:::external

    subgraph AWSAccount ["AWS Account (eu-central-1 - dev)"]
        UCStack["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/storage/simple-storage-service-s3-bucket.png' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>04_unity_catalog (environments/dev)</b><br/>(KMS CMKs, UC S3 Buckets, IAM Roles, Metastore, Catalogs, Schemas, Volumes, Secrets)"]:::system
    end

    PlatformAdmin -->|"SQL / PySpark / Volumes / SECRET()"| DatabricksCP
    DatabricksCP -->|"Assumes IAM Roles & Governs 3-Level Namespace"| UCStack
    ExternalPartner -->|"HTTPS Bearer Token (.share)"| DatabricksCP
```

### 4.2 Level 2: Container Diagram (Storage, Metastore & Multi-Workspace Governance)

```mermaid
flowchart LR
    classDef awsSec fill:#FFF3E0,stroke:#E65100,stroke-width:2px,color:#BF360C;
    classDef awsS3 fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px,color:#1B5E20;
    classDef ucGov fill:#FCE4EC,stroke:#C2185B,stroke-width:2px,color:#880E4F;
    classDef wsTier fill:#E3F2FD,stroke:#1565C0,stroke-width:2px,color:#0D47A1;

    subgraph SecurityAndStorage ["AWS KMS & S3 Storage Layer (eu-central-1)"]
        KMSKeys["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/security/key-management-service.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>KMS CMKs</b><br/>(Backend, UC Root, Ext Volumes)"]
        RootBucket["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/storage/simple-storage-service-s3-bucket.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Shared UC Root Bucket</b><br/>(Metastore + 4 Catalog Prefixes)"]
        ExtBucket["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/storage/simple-storage-service-s3-bucket.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>External Volumes Bucket</b><br/>(Partner Drop Zone)"]
    end
    class SecurityAndStorage awsS3;

    subgraph UnityCatalogLayer ["Databricks Unity Catalog Metastore & 3-Level Namespace"]
        Metastore["<img src='https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/unity-catalog.png' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Regional Metastore</b><br/>(IAM Data Access + Delta Sharing)"]
        Catalogs["<img src='https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/unity-catalog.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>4 Catalogs & 7 Schemas</b><br/>(ISOLATED + OPEN)"]
        VolumesAndSecrets["<img src='https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/enterprise-security.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>5 Volumes, UC Secrets & Open Share</b>"]
    end
    class UnityCatalogLayer ucGov;

    subgraph WorkspacesLayer ["Existing Regional Databricks E2 Workspaces"]
        WS_DE["<img src='https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/workspace.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Data Engineering</b><br/>(Primary Governance Host)"]
        WS_DS["<img src='https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/workspace.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Data Science</b>"]
        WS_BA["<img src='https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/workspace.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Business Analytics</b>"]
    end
    class WorkspacesLayer wsTier;

    KMSKeys --> RootBucket
    KMSKeys --> ExtBucket
    RootBucket --> Metastore
    RootBucket --> Catalogs
    ExtBucket --> VolumesAndSecrets
    Metastore --> Catalogs
    Catalogs --> VolumesAndSecrets
    Metastore --> WS_DE
    Metastore --> WS_DS
    Metastore --> WS_BA
```

### 4.3 Level 3: Component Diagram (Terraform Module Orchestration)

```mermaid
graph TD
    classDef moduleNode fill:#ECEFF1,stroke:#455A64,stroke-width:1.5px,color:#263238;
    classDef govNode fill:#FCE4EC,stroke:#C2185B,stroke-width:1.5px,color:#880E4F;

    KmsBackend["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/security/key-management-service.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.kms_key</b>"]:::moduleNode
    BackendBucket["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/storage/simple-storage-service-s3-bucket.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.backend_bucket</b>"]:::moduleNode
    ExtraKms["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/security/key-management-service.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.extra_kms_keys</b>"]:::moduleNode
    UcRootBucket["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/storage/simple-storage-service-s3-bucket.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.uc_root_bucket</b>"]:::moduleNode
    UcExtBucket["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/storage/simple-storage-service-s3-bucket.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.uc_external_volumes_bucket</b>"]:::moduleNode
    Metastore["<img src='https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/unity-catalog.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.metastore</b>"]:::govNode
    Assignment["<img src='https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/workspace.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.metastore_assignment</b>"]:::govNode
    Catalogs["<img src='https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/unity-catalog.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.catalogs</b>"]:::govNode
    Schemas["<img src='https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/unity-catalog.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.schemas</b>"]:::govNode
    Volumes["<img src='https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/delta-lake.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.volumes</b>"]:::govNode
    Secrets["<img src='https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/enterprise-security.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.uc_secrets</b>"]:::govNode
    OpenSharing["<img src='https://raw.githubusercontent.com/oieduardorabelo/databricks-architecture-icons/main/icons/png/delta-lake.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.open_sharing</b>"]:::govNode

    KmsBackend -->|"kms_arn"| BackendBucket
    ExtraKms -->|"uc_root_storage kms_arn"| UcRootBucket
    ExtraKms -->|"uc_external_volumes kms_arn"| UcExtBucket
    UcRootBucket -->|"bucket_name"| Metastore
    ExtraKms -->|"uc_root_storage kms_arn"| Metastore
    Metastore -->|"metastore_id"| Assignment
    Assignment -->|"depends_on"| Catalogs
    UcRootBucket -->|"bucket_name"| Catalogs
    Catalogs -->|"catalog_names"| Schemas
    Schemas -->|"schema_names"| Volumes
    UcExtBucket -->|"bucket_name"| Volumes
    ExtraKms -->|"uc_external_volumes kms_arn"| Volumes
    Schemas -->|"schema_names"| Secrets
    Schemas -->|"schema_names"| OpenSharing
    Volumes -->|"volume_full_names"| OpenSharing
```

---

## 5. All Modules Used with Short Summaries

### 5.1 Module Inventory Table

| Module Instance | Source Path | Primary Role / Responsibility |
|:---|:---|:---|
| `kms_key` | [`../../modules/02.security/001.kms_key`](../../modules/02.security/001.kms_key) | Customer-managed KMS key for Terraform S3 remote state encryption |
| `backend_bucket` | [`../../modules/03.storage/001.env_backend_bucket`](../../modules/03.storage/001.env_backend_bucket) | Versioned, SSE-KMS encrypted S3 bucket for Terraform state |
| `extra_kms_keys` | [`../../modules/02.security/001.kms_key`](../../modules/02.security/001.kms_key) | Dedicated CMKs for Unity Catalog root bucket (`uc_root_storage`) and external volumes (`uc_external_volumes`) |
| `uc_root_bucket` | [`../../modules/03.storage/002.uc_root_bucket`](../../modules/03.storage/002.uc_root_bucket) | Shared Unity Catalog S3 root bucket (`msedek-dbx-dep-uc-metastore-root-dev`) |
| `uc_external_volumes_bucket` | [`../../modules/03.storage/002.uc_root_bucket`](../../modules/03.storage/002.uc_root_bucket) | Dedicated S3 bucket (`msedek-dbx-dep-uc-ext-volumes-dev`) for `EXTERNAL` volumes |
| `metastore` | [`../../modules/04.unity_catalog/001.metastore`](../../modules/04.unity_catalog/001.metastore) | Regional Unity Catalog metastore, IAM data access role, KMS grant, and Delta Sharing config |
| `metastore_assignment` | [`../../modules/04.unity_catalog/002.metastore_assignment`](../../modules/04.unity_catalog/002.metastore_assignment) | Binds the regional metastore to existing DE, DS, and BA workspaces |
| `catalogs` | [`../../modules/04.unity_catalog/003.catalogs`](../../modules/04.unity_catalog/003.catalogs) | Provisions 4 catalogs with shared-bucket S3 prefixes, workspace bindings, and RBAC grants |
| `schemas` | [`../../modules/04.unity_catalog/004.schemas`](../../modules/04.unity_catalog/004.schemas) | Provisions 7 medallion/domain schemas and authoritative schema RBAC grants |
| `volumes` | [`../../modules/04.unity_catalog/005.volumes`](../../modules/04.unity_catalog/005.volumes) | Provisions optional external storage credential/location and 5 `MANAGED` & `EXTERNAL` volumes |
| `uc_secrets` | [`../../modules/02.security/002.uc_secrets`](../../modules/02.security/002.uc_secrets) | Provisions native Unity Catalog secrets (`databricks_secret_uc`), RBAC grants, and workspace scope |
| `open_sharing` | [`../../modules/04.unity_catalog/006.open_sharing`](../../modules/04.unity_catalog/006.open_sharing) | Provisions Open Delta Sharing share, external `TOKEN` recipient, and `SELECT` grant |

---

## 6. Terraform Documentation Interface

> [!NOTE]
> The full machine-generated Terraform interface (Providers, Modules, Inputs, Outputs, and Resource definitions) is maintained by `terraform-docs` via pre-commit hooks in [`TERRAFORM.md`](./TERRAFORM.md).

### 6.1 Essential Inputs Summary

| Variable | Type | Description | Default / Sample |
|:---|:---:|:---|:---|
| `aws_region` | `string` | Target AWS region | `"eu-central-1"` |
| `aws_account_id` | `string` | 12-digit AWS Account ID (`sensitive = true`) | `"419259485595"` |
| `environment` | `string` | Deployment environment identifier | `"dev"` |
| `databricks_account_id` | `string` | Databricks Account UUID (`sensitive = true`) | `"1980a5a1-..."` |
| `service_principal_id` | `string` | OAuth M2M Service Principal Client ID | `"b6dd846d-..."` |
| `service_principal_secret` | `string` | OAuth M2M Service Principal Secret (`sensitive = true`) | `"***"` |
| `governance_workspace_url` | `string` | Optional override for primary workspace URL (dynamically resolved if null) | `null` |

### 6.2 Essential Outputs Summary

No root outputs are declared in `environments/dev` in accordance with output minimization rules.

---

## 7. Important Links and Resources

### 7.1 Authoritative Documentation
- [Databricks Unity Catalog Administration Guide (AWS)](https://docs.databricks.com/aws/en/data-governance/unity-catalog/) - Comprehensive guide to Unity Catalog on AWS.
- [Databricks Terraform Provider Documentation](https://registry.terraform.io/providers/databricks/databricks/latest/docs) - Provider resource reference.

### 7.2 Internal References
- [Terraform Contract (`TERRAFORM.md`)](./TERRAFORM.md)
- [Root Project Documentation (`../../README.md`)](../../README.md)
- [GitHub Actions CI/CD Workflows (`../../.github/workflows/README.md`)](../../.github/workflows/README.md)
- [Authoritative README Template (`../../.ai/README_TEMPLATE.md`)](../../.ai/README_TEMPLATE.md)
