/*
  Output Values - KMS Key Module
  Documentation: https://developer.hashicorp.com/terraform/language/values/outputs

  Exports the KMS key ARN for downstream encryption usage.
*/

output "kms_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.this.arn
}
