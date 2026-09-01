# ------------------------------------------------------------------------------
# Monitoring module: a single SNS topic for alerts, plus baseline CloudWatch
# alarms for EC2 CPU and (optionally) ALB error rate / unhealthy hosts.
# Extend this module with additional alarms (disk, memory via CloudWatch
# Agent, EKS via Container Insights, etc.) as your workloads mature.
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

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  for_each = toset(var.ec2_instance_ids)

  alarm_name          = "${var.project_name}-${var.environment}-ec2-${each.value}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods   = 3
  metric_name          = "CPUUtilization"
  namespace            = "AWS/EC2"
  period               = 300
  statistic            = "Average"
  threshold            = var.cpu_alarm_threshold
  alarm_description    = "CPU utilization above ${var.cpu_alarm_threshold}% for ${each.value}"
  treat_missing_data    = "notBreaching"

  dimensions = {
    InstanceId = each.value
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  count = var.alb_arn_suffix != "" ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods   = 2
  metric_name          = "HTTPCode_Target_5XX_Count"
  namespace            = "AWS/ApplicationELB"
  period               = 300
  statistic            = "Sum"
  threshold            = var.alb_5xx_threshold
  alarm_description    = "ALB target 5xx error count above ${var.alb_5xx_threshold} in 5 minutes"
  treat_missing_data    = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  count = var.target_group_arn_suffix != "" && var.alb_arn_suffix != "" ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods   = 2
  metric_name          = "UnHealthyHostCount"
  namespace            = "AWS/ApplicationELB"
  period               = 60
  statistic            = "Average"
  threshold            = 0
  alarm_description    = "One or more ALB targets are unhealthy"
  treat_missing_data    = "notBreaching"

  dimensions = {
    TargetGroup  = var.target_group_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
