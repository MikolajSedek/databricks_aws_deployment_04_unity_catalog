/*
  Terraform, AWS, Databricks, and Time Provider Configuration - Volumes Module
  Documentation:
    - https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs
    - https://registry.terraform.io/providers/hashicorp/time/latest/docs

  Declares required Terraform version, AWS provider, workspace-level Databricks provider,
  and Time provider constraints.
*/

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.135.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
}
