/*
  Databricks Unity Catalog Governance Orchestration - Dev Environment
  Documentation:
    - https://docs.databricks.com/aws/en/data-governance/unity-catalog/get-started
    - https://docs.databricks.com/aws/en/dev-tools/terraform/automate-uc
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/unity-catalog

  Root module orchestrating end-to-end Databricks Unity Catalog governance on AWS:
    0. Metastore Admin Service Principal Membership.
    1. Remote S3 State Backend Storage & Backend KMS Key.
    2. Extra Customer-Managed KMS Keys (UC Metastore Root & Optional External Volumes).
    3. Unity Catalog Root S3 Bucket & Optional External Volumes S3 Bucket.
    4. Regional Unity Catalog Metastore, IAM Role/Policy, KMS Grant, and Default Data Access.
    5. Metastore Assignments linking existing E2 Workspaces (Data Engineering, Data Science, Analytics).
    6. Unity Catalog Catalogs with ISOLATED/OPEN Workspace Bindings and RBAC Grants.
    7. Medallion and Functional Schemas within Catalogs with RBAC Grants.
    8. Designated Volumes (MANAGED and Optional EXTERNAL with Storage Credential & External Location).
    9. Governed Secrets in Unity Catalog (databricks_secret_uc) & Workspace Secret Scopes.
    10. Basic Open Delta Sharing Setup (Shares, TOKEN Recipients, and SELECT Share Grants).
*/

/* 0. Metastore Admin Service Principal Membership in dbx-platform-admins */

resource "databricks_group_member" "deployer_admin" {
  provider  = databricks.mws
  group_id  = data.databricks_group.platform_admins.id
  member_id = data.databricks_service_principal.deployer.id
}

/* 1. Remote S3 State Backend Storage */

module "kms_key" {
  source = "../../modules/02.security/001.kms_key"

  environment         = local.env
  kms_key_alias       = "dbx_unity_catalog_backend_kms_key"
  kms_key_description = "KMS key used for backend unity catalog security"
}

module "backend_bucket" {
  source = "../../modules/03.storage/001.env_backend_bucket"

  bucket_name = local.backend_bucket_name
  environment = local.env
  kms_key_arn = module.kms_key.kms_arn
}

/* 2. Extra Customer-Managed KMS Keys for Unity Catalog Storage */

module "extra_kms_keys" {
  for_each = local.extra_kms_keys

  source = "../../modules/02.security/001.kms_key"

  environment         = local.env
  kms_key_alias       = each.value.alias
  kms_key_description = each.value.description
}

/* 3. Unity Catalog Root S3 Bucket & Optional External Volumes S3 Bucket */

module "uc_root_bucket" {
  source = "../../modules/03.storage/002.uc_root_bucket"

  bucket_name = local.uc_root_bucket_base_name
  environment = local.env
  kms_key_arn = module.extra_kms_keys["uc_root"].kms_arn
}

module "uc_external_volumes_bucket" {
  source = "../../modules/03.storage/002.uc_root_bucket"

  bucket_name = local.uc_ext_vol_bucket_base_name
  environment = local.env
  kms_key_arn = module.extra_kms_keys["uc_external_volumes"].kms_arn
}

/* 4. Regional Unity Catalog Metastore & IAM Permissions */

module "metastore" {
  source = "../../modules/04.unity_catalog/001.metastore"

  providers = {
    databricks.mws = databricks.mws
  }

  metastore_name                  = local.metastore_name
  aws_region                      = var.aws_region
  aws_account_id                  = var.aws_account_id
  databricks_account_id           = var.databricks_account_id
  bucket_name                     = module.uc_root_bucket.bucket_name
  kms_key_arn                     = module.extra_kms_keys["uc_root"].kms_arn
  iam_role_name                   = local.metastore_iam_role
  owner                           = data.databricks_service_principal.deployer.application_id
  owner_group_name                = local.admin_group_name
  delta_sharing_scope             = "INTERNAL_AND_EXTERNAL"
  delta_sharing_organization_name = "${local.project_name}-${local.env}"

  depends_on = [databricks_group_member.deployer_admin]
}

/* 5. Metastore Assignment to Existing Workspaces */

module "metastore_assignment" {
  source = "../../modules/04.unity_catalog/002.metastore_assignment"

  providers = {
    databricks.mws = databricks.mws
  }

  metastore_id  = module.metastore.metastore_id
  workspace_ids = local.workspace_ids
}

/* 6. Catalogs with Role-Based Accesses & Workspace Bindings */

module "catalogs" {
  source = "../../modules/04.unity_catalog/003.catalogs"

  providers = {
    databricks = databricks.workspace
  }

  metastore_id        = module.metastore_assignment.metastore_id
  uc_root_bucket_name = module.uc_root_bucket.bucket_name
  catalogs            = local.catalogs
}

/* 7. Schemas within Catalogs with RBAC */

module "schemas" {
  source = "../../modules/04.unity_catalog/004.schemas"

  providers = {
    databricks = databricks.workspace
  }

  catalog_names    = module.catalogs.catalog_names
  owner_group_name = local.admin_group_name
  schemas          = local.schemas
}

/* 8. Volumes - Managed and Optional External with RBAC */

module "volumes" {
  source = "../../modules/04.unity_catalog/005.volumes"

  providers = {
    databricks = databricks.workspace
  }

  metastore_id          = module.metastore_assignment.metastore_id
  aws_account_id        = var.aws_account_id
  databricks_account_id = var.databricks_account_id
  owner_group_name      = local.admin_group_name
  schema_names          = module.schemas.schema_names
  external_locations    = local.external_locations
  volumes               = local.volumes
}

/* 9. Secrets in Unity Catalog (databricks_secret_uc) & Workspace Secret Scopes */

module "uc_secrets" {
  source = "../../modules/02.security/002.uc_secrets"

  providers = {
    databricks = databricks.workspace
  }

  schema_names  = module.schemas.schema_names
  uc_secrets    = local.uc_secrets
  secret_scopes = local.secret_scopes
}

/* 10. Basic Open Delta Sharing Setup */

module "open_sharing" {
  source = "../../modules/04.unity_catalog/006.open_sharing"

  providers = {
    databricks = databricks.workspace
  }

  owner_group_name  = local.admin_group_name
  volume_full_names = module.volumes.volume_full_names
  shares            = local.open_sharing_shares
  recipients        = local.open_sharing_recipients
}
