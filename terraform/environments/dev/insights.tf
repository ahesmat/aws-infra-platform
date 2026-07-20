resource "aws_cloudwatch_query_definition" "nginx_top_requestors" {
  name = "${var.project}/${var.environment}/nginx-top-requestors"

  log_group_names = [
    "/${var.project}/${var.environment}/nginx/access"
  ]

  query_string = <<-QUERY
    fields @timestamp, @message
    | parse @message "* - -" as ip
    | stats count(*) as requests by ip
    | sort requests desc
    | limit 10
  QUERY
}

resource "aws_cloudwatch_query_definition" "nginx_error_rate" {
  name = "${var.project}/${var.environment}/nginx-error-rate"

  log_group_names = [
    "/${var.project}/${var.environment}/nginx/access"
  ]

  query_string = <<-QUERY
    fields @timestamp, @message
    | parse @message "* * * [*] \"* * *\" * *" as ip, ident, auth, timestamp, method, path, protocol, status, bytes
    | filter status >= 400
    | stats count(*) as errors by status, path
    | sort errors desc
    | limit 20
  QUERY
}

resource "aws_cloudwatch_query_definition" "nginx_slow_requests" {
  name = "${var.project}/${var.environment}/nginx-slow-requests"

  log_group_names = [
    "/${var.project}/${var.environment}/nginx/access"
  ]

  query_string = <<-QUERY
    fields @timestamp, @message
    | parse @message "* * * [*] \"* * *\" * * * *" as ip, ident, auth, timestamp, method, path, protocol, status, bytes, referer, agent
    | sort @timestamp desc
    | limit 50
  QUERY
}

resource "aws_cloudwatch_query_definition" "nginx_request_volume" {
  name = "${var.project}/${var.environment}/nginx-request-volume"

  log_group_names = [
    "/${var.project}/${var.environment}/nginx/access"
  ]

  query_string = <<-QUERY
    fields @timestamp, @message
    | stats count(*) as requests by bin(5m)
    | sort @timestamp asc
  QUERY
}
