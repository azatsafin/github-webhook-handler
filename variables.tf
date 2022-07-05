variable "resource_name_prefix" {
  default = "github_handler"
  description = "Specify your project name here, all resource name will be used this string as a prefix in resource names ex:module-resource-name"
}

variable "github_secret" {
  type = string
  description = "github secret used to sign hash of payload"
}

variable "aws_region" {
  type = string
  description = "aws region for deployment"
  default = "eu-central-1"
}