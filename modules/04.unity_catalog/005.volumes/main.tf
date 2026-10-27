/*
  Unity Catalog Volumes (Managed & Optional External), Storage Credentials, and External Locations
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/volume
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/storage_credential
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/external_location
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants

  Provisions third-level namespace Unity Catalog Volumes for non-tabular files:
    1. Optional External Storage Infrastructure: When var.external_locations is populated,
       provisions the least-privilege AWS IAM role, S3/KMS policy, KMS grant, 30-second
       STS propagation delay, databricks_storage_credential, and databricks_external_location.
    2. Unity Catalog Volumes: Creates MANAGED volumes (stored automatically inside the
       parent schema's managed root location) and optional EXTERNAL volumes (mapped to
       a governed external location URL).
    3. Authoritative Volume Grants: Enforces READ_VOLUME and WRITE_VOLUME RBAC permissions.
*/

/* 1. Optional External Storage IAM Roles, KMS Grants, Credentials & External Locations */
data "databricks_aws_unity_catalog_assume_role_policy" "external" {
  for_each = var.external_locations

  aws_account_id = var.aws_account_id
  role_name      = each.value.iam_role_name
  external_id    = var.databricks_account_id
}

data "databricks_aws_unity_catalog_policy" "external" {
  for_each = var.external_locations

  aws_account_id = var.aws_account_id
  bucket_name    = each.value.bucket_name
  role_name      = each.value.iam_role_name
  kms_name       = each.value.kms_key_arn
}

resource "aws_iam_role" "external" {
  for_each = var.external_locations

  name               = each.value.iam_role_name
  description        = "IAM role assumed by Databricks Unity Catalog for external location ${each.value.name}"
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.external[each.key].json

  tags = merge(
    var.tags,
    {
      Name = each.value.iam_role_name
    }
  )
}

resource "aws_iam_policy" "external" {
  for_each = var.external_locations

  name        = "${each.value.iam_role_name}-policy"
  description = "Least-privilege S3 and KMS policy for Unity Catalog external location ${each.value.name}"
  policy      = data.databricks_aws_unity_catalog_policy.external[each.key].json

  tags = merge(
    var.tags,
    {
      Name = "${each.value.iam_role_name}-policy"
    }
  )
}

resource "aws_iam_role_policy_attachment" "external" {
  for_each = var.external_locations

  role       = aws_iam_role.external[each.key].name
  policy_arn = aws_iam_policy.external[each.key].arn
}

resource "aws_kms_grant" "external" {
  for_each = var.external_locations

  name              = "dbx-uc-ext-loc-grant-${each.key}"
  key_id            = each.value.kms_key_arn
  grantee_principal = aws_iam_role.external[each.key].arn
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

resource "time_sleep" "wait_for_external_iam" {
  for_each = var.external_locations

  depends_on = [
    aws_iam_role_policy_attachment.external,
    aws_kms_grant.external
  ]
  create_duration = "30s"
}

resource "databricks_storage_credential" "external" {
  for_each = var.external_locations

  name           = "${each.value.name}-cred"
  metastore_id   = var.metastore_id
  read_only      = coalesce(each.value.read_only, false)
  isolation_mode = coalesce(each.value.isolation_mode, "ISOLATION_MODE_OPEN")
  force_destroy  = coalesce(each.value.force_destroy, false)
  comment        = each.value.comment

  aws_iam_role {
    role_arn = aws_iam_role.external[each.key].arn
  }

  depends_on = [time_sleep.wait_for_external_iam]
}

resource "databricks_external_location" "external" {
  for_each = var.external_locations

  name            = each.value.name
  url             = "s3://${each.value.bucket_name}/${coalesce(each.value.s3_subpath, "external-volumes")}"
  credential_name = databricks_storage_credential.external[each.key].name
  owner           = var.owner_group_name
  read_only       = coalesce(each.value.read_only, false)
  isolation_mode  = coalesce(each.value.isolation_mode, "ISOLATION_MODE_OPEN")
  force_destroy   = coalesce(each.value.force_destroy, false)
  comment         = each.value.comment

  encryption_details {
    sse_encryption_details {
      algorithm       = "AWS_SSE_KMS"
      aws_kms_key_arn = each.value.kms_key_arn
    }
  }
}

resource "databricks_grants" "external_location" {
  for_each = local.external_locations_with_grants

  external_location = databricks_external_location.external[each.key].id

  dynamic "grant" {
    for_each = each.value.grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}

/* 2. Unity Catalog Volumes (MANAGED and Optional EXTERNAL) */
resource "databricks_volume" "this" {
  for_each = var.volumes

  catalog_name = var.schema_names[each.value.schema_key].catalog_name
  schema_name  = var.schema_names[each.value.schema_key].schema_name
  name         = each.value.name
  volume_type  = coalesce(each.value.volume_type, "MANAGED")
  owner        = coalesce(each.value.owner, var.owner_group_name)
  comment      = each.value.comment

  storage_location = (
    coalesce(each.value.volume_type, "MANAGED") == "EXTERNAL"
    ? "${databricks_external_location.external[each.value.external_location_key].url}/${coalesce(each.value.external_subpath, each.value.name)}"
    : null
  )

  depends_on = [databricks_grants.external_location]
}

/* 3. Volume Role-Based Access Control (RBAC) Grants */
resource "databricks_grants" "volume" {
  for_each = local.volumes_with_grants

  volume = databricks_volume.this[each.key].id

  dynamic "grant" {
    for_each = each.value.grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}
