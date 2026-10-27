/*
  Local Values - KMS Key Module
  Documentation: https://developer.hashicorp.com/terraform/language/values/locals

  Defines internal naming conventions and alias calculations for the KMS key.
*/

locals {
  kms_key_alias_with_env = "${var.kms_key_alias}-${var.environment}"
}
