output "alb_dns_name" {
  description = "Public DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.this.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the load balancer (used for CloudWatch metric dimensions)"
  value       = aws_lb.this.arn_suffix
}

output "target_group_arn" {
  description = "ARN of the target group EC2 instances should register with"
  value       = aws_lb_target_group.this.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the target group (used for CloudWatch metric dimensions)"
  value       = aws_lb_target_group.this.arn_suffix
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB (allow this in the EC2 security group)"
  value       = aws_security_group.alb.id
}
