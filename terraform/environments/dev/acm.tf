resource "aws_acm_certificate" "cert" {
  domain_name       = "devops.reachlyapp.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project}-${var.environment}-acm"
  }
}
