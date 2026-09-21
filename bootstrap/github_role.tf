data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    sid    = "AllowGitHubActionsProduction"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github_actions.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repository}@${var.github_repository_id}:environment:${var.github_environment}"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name = "cloudcontent-github-actions"

  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json

  tags = {
    Name    = "cloudcontent-github-actions"
    Project = "CloudContent"
  }
}