locals {
  lambda_authorizer_function_name = "${var.resource_name_prefix}-github-webhook-handler-lambda"
}

module "webhook_lambda_handler" {
  source          = "terraform-aws-modules/lambda/aws"
  version         = "3.2.1"
  create_package  = true
  create_role     = true
  create          = true
  create_layer    = false
  create_function = true
  publish         = true
  function_name   = local.lambda_authorizer_function_name
  runtime         = "python3.9"
  handler         = "app.handler"
  memory_size     = 512
  timeout         = 30
  package_type    = "Zip"
  source_path     = "${path.module}/lambdas/webhook-lambda"

  environment_variables = {
    SSM_GITHUB_SECRET_PATH = local.ssm_github_webhook_secret_path
  }
}
