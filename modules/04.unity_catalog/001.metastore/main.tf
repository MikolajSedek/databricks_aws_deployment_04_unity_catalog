/*
  Unity Catalog Metastore, Cross-Account IAM Role, KMS Grant, and Data Access Configuration
  Documentation:
    - https://docs.databricks.com/aws/en/data-governance/unity-catalog/get-started
    - https://docs.databricks.com/aws/en/dev-tools/terraform/automate-uc
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_data_access

  Orchestrates the regional Unity Catalog metastore and its cloud storage credentials:
    1. Constructs the official Databricks UC assume-role trust policy (with self-assumption support)
       and least-privilege S3/KMS access policy via Databricks provider data sources.
    2. Provisions the AWS IAM role, IAM policy attachment, and KMS cryptographic grant.
    3. Waits 30 seconds for AWS IAM and STS eventual consistency propagation.
    4. Provisions the regional Unity Catalog metastore with Delta Sharing enabled.
    5. Binds the IAM role to the metastore via databricks_metastore_data_access (is_default = true).
*/

/* 1. Official Databricks Unity Catalog IAM Assume-Role Trust Policy */
data "databricks_aws_unity_catalog_assume_role_policy" "this" {
  provider       = databricks.mws
  aws_account_id = var.aws_account_id
  role_name      = var.iam_role_name
  external_id    = var.databricks_account_id
}

/* 2. Official Databricks Unity Catalog Least-Privilege S3 & KMS Access Policy */
data "databricks_aws_unity_catalog_policy" "this" {
  provider       = databricks.mws
  aws_account_id = var.aws_account_id
  bucket_name    = var.bucket_name
  role_name      = var.iam_role_name
  kms_name       = var.kms_key_arn
}

/* 3. AWS IAM Role and Policy Attachment for Unity Catalog Metastore Access */
resource "aws_iam_role" "metastore_data_access" {
  name               = var.iam_role_name
  description        = "IAM role assumed by Databricks Unity Catalog to govern metastore S3 root storage"
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.this.json

  tags = merge(
    var.tags,
    {
      Name = var.iam_role_name
    }
  )
}

resource "aws_iam_policy" "metastore_data_access" {
  name        = "${var.iam_role_name}-policy"
  description = "Least-privilege S3 and KMS policy for Databricks Unity Catalog metastore root storage"
  policy      = data.databricks_aws_unity_catalog_policy.this.json

  tags = merge(
    var.tags,
    {
      Name = "${var.iam_role_name}-policy"
    }
  )
}

resource "aws_iam_role_policy_attachment" "metastore_data_access" {
  role       = aws_iam_role.metastore_data_access.name
  policy_arn = aws_iam_policy.metastore_data_access.arn
}

/* 4. Explicit AWS KMS Grant for the Unity Catalog Metastore IAM Role */
resource "aws_kms_grant" "metastore_data_access" {
  name              = "dbx-uc-metastore-grant-${var.bucket_name}"
  key_id            = var.kms_key_arn
  grantee_principal = aws_iam_role.metastore_data_access.arn
  operations = [
    "Encrypt",
    "Decrypt",
    "GenerateDataKey",
    "GenerateDataKeyWithoutPlaintext",
    "ReEncryptFrom",
    "ReEncryptTo",
    "CreateGrant",
    "DescribeKey"
  ]
}

/*
  5. Wait 30 seconds for AWS IAM role, policy attachment, and KMS grant eventual consistency
  propagation across global STS endpoints before Databricks validates credentials.
*/
resource "time_sleep" "wait_for_iam_propagation" {
  depends_on = [
    aws_iam_role_policy_attachment.metastore_data_access,
    aws_kms_grant.metastore_data_access
  ]
  create_duration = "30s"
}

/* 6. Regional Unity Catalog Metastore (Single Metastore per Region) */
resource "databricks_metastore" "this" {
  provider                                          = databricks.mws
  name                                              = var.metastore_name
  region                                            = var.aws_region
  storage_root                                      = "s3://${var.bucket_name}/metastore"
  owner                                             = var.owner != null ? var.owner : var.owner_group_name
  delta_sharing_scope                               = var.delta_sharing_scope
  delta_sharing_recipient_token_lifetime_in_seconds = var.delta_sharing_recipient_token_lifetime_in_seconds
  delta_sharing_organization_name                   = var.delta_sharing_organization_name
  force_destroy                                     = var.force_destroy

  depends_on = [time_sleep.wait_for_iam_propagation]
}

/* 7. Default Metastore Data Access Configuration (Storage Credential Binding) */
resource "databricks_metastore_data_access" "this" {
  provider     = databricks.mws
  metastore_id = databricks_metastore.this.id
  name         = aws_iam_role.metastore_data_access.name
  is_default   = true
  owner        = var.owner != null ? var.owner : var.owner_group_name

  aws_iam_role {
    role_arn = aws_iam_role.metastore_data_access.arn
  }

  depends_on = [time_sleep.wait_for_iam_propagation]
}
