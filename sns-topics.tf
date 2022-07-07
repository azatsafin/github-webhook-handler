resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.webhook_payload.arn
  policy = data.aws_iam_policy_document.webhook_payload_topic_policy.json
}

data "aws_iam_policy_document" "webhook_payload_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    sid = "__publish_from_github_webhook"

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [
        local.account_id
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.webhook_payload.arn
    ]
  }
}

resource "aws_sns_topic" "webhook_payload" {
  name         = "${var.resource_name_prefix}-github-webhook-payloads"
  display_name = "${var.resource_name_prefix}-github-webhook-payloads"
}
