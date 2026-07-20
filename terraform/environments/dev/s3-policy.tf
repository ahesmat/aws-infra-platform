data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = "tfstate-aws-infra-platform-${data.aws_caller_identity.current.account_id}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyPublicAccess"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::tfstate-aws-infra-platform-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::tfstate-aws-infra-platform-${data.aws_caller_identity.current.account_id}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "AllowTerraformAccess"
        Effect = "Allow"
        Principal = {
          AWS = [
            data.aws_caller_identity.current.arn,
            aws_iam_role.github_actions.arn
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::tfstate-aws-infra-platform-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::tfstate-aws-infra-platform-${data.aws_caller_identity.current.account_id}/*"
        ]
      }
    ]
  })
}
