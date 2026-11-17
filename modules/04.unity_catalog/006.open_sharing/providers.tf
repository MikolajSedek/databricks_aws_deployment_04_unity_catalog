/*
  Terraform and Databricks Provider Configuration - Open Delta Sharing Module
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs

  Declares required Terraform version and workspace-level Databricks provider constraints.
*/

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.135.0"
    }
  }
}
