data "aws_iam_policy_document" "terraform_plan_foundation" {

  # ---------------------------------------------------------------------------
  # EC2 / VPC
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ReadVpcInfrastructure"
    effect = "Allow"

    actions = [
      "ec2:Describe*",
      "ec2:GetManagedPrefixListEntries"
    ]

    resources = ["*"]
  }


  # ---------------------------------------------------------------------------
  # RDS
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ReadRdsInfrastructure"
    effect = "Allow"

    actions = [
      "rds:Describe*",
      "rds:ListTagsForResource"
    ]

    resources = ["*"]
  }


  # ---------------------------------------------------------------------------
  # ECR
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ReadEcrInfrastructure"
    effect = "Allow"

    actions = [
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:GetLifecyclePolicy",
      "ecr:GetRepositoryPolicy",
      "ecr:ListTagsForResource"
    ]

    resources = ["*"]
  }


  # ---------------------------------------------------------------------------
  # IAM - CloudContent application role
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ReadCloudContentAppRole"
    effect = "Allow"

    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListRoleTags"
    ]

    resources = [
      local.app_role_arn
    ]
  }


  # ---------------------------------------------------------------------------
  # IAM - CloudContent application policies
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ReadCloudContentAppPolicies"
    effect = "Allow"

    actions = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:ListPolicyTags"
    ]

    resources = local.app_policy_arns
  }


  # ---------------------------------------------------------------------------
  # IAM - CloudContent EC2 role
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ReadCloudContentEc2Role"
    effect = "Allow"

    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListRoleTags",
      "iam:ListInstanceProfilesForRole"
    ]

    resources = [
      local.ec2_role_arn
    ]
  }


  # ---------------------------------------------------------------------------
  # IAM - CloudContent EC2 instance profile
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ReadCloudContentEc2InstanceProfile"
    effect = "Allow"

    actions = [
      "iam:GetInstanceProfile"
    ]

    resources = [
      local.ec2_instance_profile_arn
    ]
  }


  # ---------------------------------------------------------------------------
  # S3 content buckets
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ReadCloudContentBuckets"
    effect = "Allow"

    actions = [
      "s3:GetBucket*",
      "s3:GetEncryptionConfiguration",
      "s3:GetAccelerateConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:ListBucket",
      "s3:ListBucketVersions"
    ]

    resources = [
      local.free_content_bucket_arn,
      local.premium_content_bucket_arn
    ]
  }


  # ---------------------------------------------------------------------------
  # KMS
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ReadKmsMetadata"
    effect = "Allow"

    actions = [
      "kms:DescribeKey"
    ]

    resources = ["*"]
  }


  # ---------------------------------------------------------------------------
  # Secrets Manager
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ReadSecretsMetadata"
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = ["*"]
  }
}


resource "aws_iam_policy" "terraform_plan_foundation" {
  name        = "cloudcontent-terraform-plan-read"
  description = "Allows GitHub Actions pull request plans to read CloudContent AWS foundation resources"

  policy = data.aws_iam_policy_document.terraform_plan_foundation.json

  tags = {
    Name    = "cloudcontent-terraform-plan-read"
    Project = "CloudContent"
  }
}


resource "aws_iam_role_policy_attachment" "terraform_plan_foundation" {
  role       = aws_iam_role.github_plan.name
  policy_arn = aws_iam_policy.terraform_plan_foundation.arn
}