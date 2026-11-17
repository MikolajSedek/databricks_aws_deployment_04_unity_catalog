/*
  Terraform and Databricks Provider Configuration - Metastore Assignment Module
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs

  Declares required Terraform version and Databricks MWS account-level provider alias.
*/

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    databricks = {
      source                = "databricks/databricks"
      version               = ">= 1.135.0"
      configuration_aliases = [databricks.mws]
    }
  }
}
