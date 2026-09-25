# -----------------------------------------------------------------------------
# EC2 Systems Manager
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid    = "AllowEc2AssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name = "${local.name_prefix}-ec2"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2"
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role = aws_iam_role.ec2.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name_prefix}-ec2"

  role = aws_iam_role.ec2.name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2"
  })
}

data "aws_iam_policy_document" "ansible_artifacts_read" {

  statement {
    sid    = "ListAnsibleArtifacts"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [
      aws_s3_bucket.ansible_artifacts.arn,
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "ansible/*",
      ]
    }
  }

  statement {
    sid    = "ReadAnsibleArtifacts"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.ansible_artifacts.arn}/ansible/*",
    ]
  }
}

resource "aws_iam_policy" "ansible_artifacts_read" {
  name = "${local.name_prefix}-ansible-artifacts-read"

  policy = data.aws_iam_policy_document.ansible_artifacts_read.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_ansible_artifacts_read" {
  role = aws_iam_role.ec2.name

  policy_arn = aws_iam_policy.ansible_artifacts_read.arn
}