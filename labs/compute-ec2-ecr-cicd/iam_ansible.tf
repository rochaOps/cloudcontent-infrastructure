data "aws_iam_policy_document" "ansible_artifacts_read" {
  statement {
    sid       = "LocateArtifactsBucket"
    actions   = ["s3:GetBucketLocation"]
    resources = [aws_s3_bucket.ansible_artifacts.arn]
  }

  statement {
    sid       = "ListAnsibleArtifacts"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.ansible_artifacts.arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["ansible/*"]
    }
  }

  statement {
    sid       = "ReadAnsibleArtifacts"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.ansible_artifacts.arn}/ansible/*"]
  }
}

resource "aws_iam_policy" "ansible_artifacts_read" {
  name   = "${local.name_prefix}-ansible-artifacts-read"
  policy = data.aws_iam_policy_document.ansible_artifacts_read.json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_ansible_artifacts_read" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ansible_artifacts_read.arn
}
