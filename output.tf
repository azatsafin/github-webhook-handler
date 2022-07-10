output "sns_topic_arn" {
  value = aws_sns_topic.webhook_payload.arn
}

output "webhook_api_url" {
  value = "${module.api_github_webhook_handler.default_apigatewayv2_stage_invoke_url}webhook_handler"
}