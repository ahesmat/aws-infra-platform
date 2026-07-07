output "instance_id" {
  description = "The EC2 instance ID (used for SSM connections)"
  value       = aws_instance.main.id
}

output "alb_dns_name" {
  description = "ALB DNS Name"
  value       = aws_lb.main.dns_name
}

output "site_url" {
  description = "Live HTTPS URL for the deployed site"
  value       = "https://devops.reachlyapp.com"
}

output "route53_name_servers" {
  description = "Route 53 Name Servers"
  value       = aws_route53_zone.main.name_servers
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC authentication"
  value       = aws_iam_role.github_actions.arn
}
