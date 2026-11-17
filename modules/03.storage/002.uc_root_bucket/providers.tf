/*
  Terraform, AWS, and Databricks Provider Configuration - UC Root Bucket Module
  Documentation:
    - https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs

  Declares required Terraform version and AWS provider constraints for the
  Unity Catalog S3 storage bucket module.
*/

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
