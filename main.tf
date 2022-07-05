data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      "Project" = var.resource_name_prefix
    }
  }
}