/*
  Terraform and AWS Provider Configuration - S3 Backend Bucket Module
  Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

  Declares required Terraform binary version and the AWS provider constraints.
*/

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
}
