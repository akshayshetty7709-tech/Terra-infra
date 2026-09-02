# ------------------------------------------------------------------------------
# Monitoring module: SNS topic for alerts, with an optional email subscription.
# Attach CloudWatch alarms to this topic's ARN (aws_sns_topic.alerts.arn / the
# sns_topic_arn output) from any module - e.g. EKS node CPU/memory via
# Container Insights, S3 request errors, CloudFront error rate, etc.
# ------------------------------------------------------------------------------

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = {
    Name = "${var.project_name}-${var.environment}-alerts"
  }
}

resource "aws_sns_topic_subscription" "email" {
  count = var.alarm_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}
