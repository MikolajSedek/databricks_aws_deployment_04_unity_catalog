/*
  Input Variables Definition - Dev Environment
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/variables
    - https://docs.databricks.com/en/resources/supported-regions.html

  Declares configuration variables for the dev Unity Catalog environment:
    - Target AWS deployment settings (region, account ID, profile, environment).
    - Databricks account credentials (account ID, OAuth client ID, and sensitive client secret).
    - Primary governance workspace URL and optional sensitive secret values for Unity Catalog secrets.
*/

variable "aws_region" {
  description = "The AWS region where resources will be deployed."
  type        = string
  default     = "eu-central-1"

  validation {
    condition     = can(regex("^[a-z]{2}(-[a-z]+)+-\\d$", var.aws_region))
    error_message = "The AWS region must be a valid region format (e.g. eu-central-1, us-east-1)."
  }
}

variable "aws_account_id" {
  description = "The allowed AWS Account ID to prevent accidental deployment to the wrong account."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "The AWS Account ID must be a 12-digit number."
  }
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "profile" {
  description = "AWS CLI user profile"
  type        = string
  default     = "default"
}

variable "service_principal_id" {
  description = "The service principal ID for the Databricks workspace / account"
  type        = string
}

variable "service_principal_secret" {
  description = "The service principal secret for the Databricks workspace / account"
  type        = string
  sensitive   = true
}

variable "databricks_account_id" {
  description = "The Databricks account ID (UUID) used by the account-level provider."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", var.databricks_account_id))
    error_message = "The Databricks account ID must be a valid UUID."
  }
}

variable "governance_workspace_url" {
  description = "Optional override for the workspace URL of the primary Databricks workspace (Data Engineering). When null, dynamically resolved via data.databricks_current_user."
  type        = string
  default     = null

  validation {
    condition     = var.governance_workspace_url == null || can(regex("^https://[a-z0-9-]+\\.cloud\\.databricks\\.com/?$", var.governance_workspace_url))
    error_message = "The governance_workspace_url must be a valid Databricks workspace HTTPS URL."
  }
}

variable "uc_external_api_key_secret" {
  description = "Sensitive secret value stored in Unity Catalog secret (shared_enterprise_dev.security_vault.external_ingestion_api_key)."
  type        = string
  sensitive   = true
  default     = "placeholder-uc-external-ingestion-api-key-change-me"
}

variable "uc_jdbc_password_secret" {
  description = "Sensitive secret value stored in Unity Catalog secret (data_engineering_dev.raw_ingestion.erp_jdbc_password)."
  type        = string
  sensitive   = true
  default     = "placeholder-uc-erp-jdbc-password-change-me"
}
