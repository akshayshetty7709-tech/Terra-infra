# ------------------------------------------------------------------------------
# EC2 module: security group + one or more EC2 instances spread across the
# given subnets. Uses the latest Amazon Linux 2023 AMI by default.
# ------------------------------------------------------------------------------

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Security group for ${var.project_name} ${var.environment} EC2 instances"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_ssh_cidrs) > 0 ? [1] : []
    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_ssh_cidrs
    }
  }

  # HTTP: if an ALB security group is provided, only allow traffic from the
  # ALB (recommended). Otherwise fall back to open internet access.
  dynamic "ingress" {
    for_each = var.alb_security_group_id != "" ? [1] : []
    content {
      description     = "HTTP from ALB"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [var.alb_security_group_id]
    }
  }

  dynamic "ingress" {
    for_each = var.alb_security_group_id == "" ? [1] : []
    content {
      description = "HTTP (open - no ALB configured)"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-sg"
  }
}

resource "aws_instance" "this" {
  count                  = var.instance_count
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = element(var.subnet_ids, count.index % length(var.subnet_ids))
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.key_name != "" ? var.key_name : null

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-${count.index + 1}"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count = var.target_group_arn != "" ? var.instance_count : 0

  target_group_arn = var.target_group_arn
  target_id        = aws_instance.this[count.index].id
  port             = 80
}
