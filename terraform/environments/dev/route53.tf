resource "aws_route53_zone" "main" {
  name          = "devops.reachlyapp.com"
  comment       = "Public hosted zone for devops.reachlyapp.com"
  force_destroy = false

  tags = {
    Name = "${var.project}-${var.environment}-route53"
  }
}

