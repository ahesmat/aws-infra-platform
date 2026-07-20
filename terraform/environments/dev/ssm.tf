resource "aws_ssm_parameter" "site_url" {
  name        = "/${var.project}/${var.environment}/site-url"
  description = "Live HTTPS URL for the deployed site"
  type        = "String"
  value       = "https://devops.reachlyapp.com"

  tags = {
    Name = "${var.project}-${var.environment}-site-url"
  }
}

resource "aws_ssm_parameter" "alb_dns" {
  name        = "/${var.project}/${var.environment}/alb-dns"
  description = "ALB DNS name"
  type        = "String"
  value       = aws_lb.main.dns_name

  tags = {
    Name = "${var.project}-${var.environment}-alb-dns"
  }
}

resource "aws_ssm_parameter" "instance_id" {
  name        = "/${var.project}/${var.environment}/instance-id"
  description = "EC2 instance ID"
  type        = "String"
  value       = aws_instance.main.id

  tags = {
    Name = "${var.project}-${var.environment}-instance-id"
  }
}

resource "aws_ssm_parameter" "environment" {
  name        = "/${var.project}/${var.environment}/environment"
  description = "Current deployment environment"
  type        = "String"
  value       = var.environment

  tags = {
    Name = "${var.project}-${var.environment}-environment"
  }
}
