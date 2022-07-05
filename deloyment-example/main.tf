module "github_webhook_handler" {
  source = "../"
  aws_region = "eu-central-1"
  github_secret = var.github_secret
}

variable "github_secret" {
  type = string
}