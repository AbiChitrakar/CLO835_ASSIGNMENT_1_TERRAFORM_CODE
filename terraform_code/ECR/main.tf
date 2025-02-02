#  Define the provider
provider "aws" {
  region = "us-east-1"
}

# Define tags locally
locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  name_prefix  = "${local.prefix}-${var.env}"
}

# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "../modules/globalvars"
}

# Create ECR repository for Webapp
resource "aws_ecr_repository" "webapp_repo" {
  name = "webapp-repo"
}
# Create ECR repository for MySQL
resource "aws_ecr_repository" "mysql_repo" {
  name = "mysql-repo"
}
