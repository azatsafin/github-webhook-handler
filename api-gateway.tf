module "api_github_webhook_handler" {
  source                 = "terraform-aws-modules/apigateway-v2/aws"
  version                = "v1.8.0"
  name                   = "${var.resource_name_prefix}-github-webhook-handler"
  description            = "API for interacting with oauth2 lambda functions"
  protocol_type          = "HTTP"
  create_api_domain_name = false
  default_route_settings = {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 100
    throttling_rate_limit    = 100
  }

  integrations = {
    "GET /webhook_handler" = {
      lambda_arn             = module.webhook_lambda_handler.lambda_function_arn
      payload_format_version = "2.0"
      integration_type       = "AWS_PROXY"
    }
  }
}

resource "aws_lambda_permission" "github_webhook_handler" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = element(split(":", "${module.webhook_lambda_handler.lambda_function_arn}"),
  length(split(":", "${module.webhook_lambda_handler.lambda_function_arn}"))-1)
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_github_webhook_handler.apigatewayv2_api_execution_arn}/*/*/*"
}
