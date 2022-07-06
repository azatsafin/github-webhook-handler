locals  {
  ssm_github_webhook_secret_path = "${var.resource_name_prefix}-github-webkook-secret"
}
resource "aws_ssm_parameter" "github_secret" {
  data_type   = "text"
  description = "github webhook secret"
  name        = local.ssm_github_webhook_secret_path
  type        = "String"
  value       = var.github_secret
}