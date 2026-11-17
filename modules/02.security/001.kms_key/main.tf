/*
  AWS Key Management Service (KMS) Customer Managed Key Definition
  Documentation:
    - https://docs.aws.amazon.com/kms/latest/developerguide/overview.html
    - https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
    - https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html

  Provisions a customer-managed KMS key (CMK) and key alias for encrypting
  sensitive infrastructure components, such as remote Terraform state buckets
  and DynamoDB state locking tables, with configurable automatic key rotation
  and deletion protection windows.
*/

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "this" {
  description             = var.kms_key_description
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_key_policy" "this" {
  key_id = aws_kms_key.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "this" {
  target_key_id = aws_kms_key.this.id
  name          = "alias/${local.kms_key_alias_with_env}"

  lifecycle {
    prevent_destroy = true
  }
}
