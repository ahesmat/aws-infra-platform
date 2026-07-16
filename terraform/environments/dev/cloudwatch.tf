resource "aws_cloudwatch_log_group" "nginx_access" {
  name              = "/${var.project}/${var.environment}/nginx/access"
  retention_in_days = 7

  tags = {
    Name = "${var.project}-${var.environment}-nginx-access-logs"
  }
}

resource "aws_cloudwatch_log_group" "nginx_error" {
  name              = "/${var.project}/${var.environment}/nginx/error"
  retention_in_days = 7

  tags = {
    Name = "${var.project}-${var.environment}-nginx-error-logs"
  }
}
