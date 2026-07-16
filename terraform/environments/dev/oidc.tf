resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:ahesmat/aws-infra-platform:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.project}-${var.environment}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json

  tags = {
    Name = "${var.project}-${var.environment}-github-actions-role"
  }
}

data "aws_iam_policy_document" "github_actions_document" {
  statement {
    sid    = "GitHubActionsPermissions"
    effect = "Allow"

    actions = [
      "ec2:*",
      "s3:*",
      "iam:*",
      "dynamodb:*",
      "elasticloadbalancing:*",
      "route53:*",
      "acm:*",
      "ssm:*",
      "cloudwatch:*",
      "logs:*",
      "sns:*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions" {
  name        = "${var.project}-${var.environment}-github-actions-policy"
  description = "Permissions for GitHub Actions CI/CD pipeline"
  policy      = data.aws_iam_policy_document.github_actions_document.json
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}
