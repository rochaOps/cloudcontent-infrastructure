locals {
  free_content_bucket_arn = "arn:${data.aws_partition.current.partition}:s3:::cloudcontent-free-content-${data.aws_caller_identity.current.account_id}"

  premium_content_bucket_arn = "arn:${data.aws_partition.current.partition}:s3:::cloudcontent-premium-content-${data.aws_caller_identity.current.account_id}"

  app_role_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/cloudcontent-app"

  app_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:policy/cloudcontent-app-rds-connect",
    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:policy/cloudcontent-app-s3-content"
  ]
}

data "aws_iam_policy_document" "terraform_foundation" {

  # ---------------------------------------------------------------------------
  # EC2 / VPC - read
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
  # EC2 / VPC - networking management
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ManageVpcInfrastructure"
    effect = "Allow"

    actions = [
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:ModifyVpcAttribute",

      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:ModifySubnetAttribute",

      "ec2:CreateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable",
      "ec2:CreateRoute",
      "ec2:ReplaceRoute",
      "ec2:DeleteRoute",

      "ec2:CreateInternetGateway",
      "ec2:AttachInternetGateway",
      "ec2:DetachInternetGateway",
      "ec2:DeleteInternetGateway",

      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",

      "ec2:CreateVpcEndpoint",
      "ec2:ModifyVpcEndpoint",
      "ec2:DeleteVpcEndpoints",

      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]

    resources = ["*"]
  }


  # ---------------------------------------------------------------------------
  # S3 content buckets
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ManageCloudContentBuckets"
    effect = "Allow"

    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:GetBucket*",
      "s3:PutBucket*",
      "s3:DeleteBucket*",
      "s3:GetEncryptionConfiguration",
      "s3:GetAccelerateConfiguration",
      "s3:PutEncryptionConfiguration",
      "s3:DeleteBucketEncryption",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:ListBucket",
      "s3:ListBucketVersions"
    ]

    resources = [
      local.free_content_bucket_arn,
      "${local.free_content_bucket_arn}/*",

      local.premium_content_bucket_arn,
      "${local.premium_content_bucket_arn}/*"
    ]
  }


  # ---------------------------------------------------------------------------
  # ECR - read
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ReadEcrRepositories"
    effect = "Allow"

    actions = [
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:GetLifecyclePolicy",
      "ecr:ListTagsForResource"
    ]

    resources = ["*"]
  }


  # ---------------------------------------------------------------------------
  # ECR - repository management
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ManageCloudContentEcrRepositories"
    effect = "Allow"

    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:PutImageScanningConfiguration",
      "ecr:PutImageTagMutability",
      "ecr:PutLifecyclePolicy",
      "ecr:DeleteLifecyclePolicy",
      "ecr:TagResource",
      "ecr:UntagResource"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/cloudcontent-*"
    ]
  }


  # ---------------------------------------------------------------------------
  # RDS - read
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
  # RDS - database/subnet group management
  # ---------------------------------------------------------------------------

  statement {
    sid    = "ManageCloudContentRds"
    effect = "Allow"

    actions = [
      "rds:CreateDBInstance",
      "rds:ModifyDBInstance",
      "rds:DeleteDBInstance",

      "rds:CreateDBSubnetGroup",
      "rds:ModifyDBSubnetGroup",
      "rds:DeleteDBSubnetGroup",

      "rds:AddTagsToResource",
      "rds:RemoveTagsFromResource"
    ]

    resources = ["*"]
  }


  # ---------------------------------------------------------------------------
  # RDS managed master password
  # ---------------------------------------------------------------------------

  statement {
    sid    = "CreateRdsManagedSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:TagResource"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "DescribeSecretsManagerKmsKey"
    effect = "Allow"

    actions = [
      "kms:DescribeKey"
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

  statement {
    sid    = "ManageCloudContentAppRole"
    effect = "Allow"

    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:TagRole",
      "iam:UntagRole"
    ]

    resources = [
      local.app_role_arn
    ]
  }


  # ---------------------------------------------------------------------------
  # IAM - policies owned by the CloudContent application
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

  statement {
    sid    = "ManageCloudContentAppPolicies"
    effect = "Allow"

    actions = [
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:SetDefaultPolicyVersion",
      "iam:TagPolicy",
      "iam:UntagPolicy"
    ]

    resources = local.app_policy_arns
  }


  # ---------------------------------------------------------------------------
  # IAM - attach only CloudContent application policies to the app role
  # ---------------------------------------------------------------------------

  statement {
    sid    = "AttachCloudContentAppPolicies"
    effect = "Allow"

    actions = [
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy"
    ]

    resources = [
      local.app_role_arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "iam:PolicyARN"

      values = local.app_policy_arns
    }
  }


  # ---------------------------------------------------------------------------
  # RDS service-linked role
  # ---------------------------------------------------------------------------

  statement {
    sid    = "CreateRdsServiceLinkedRole"
    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"

      values = [
        "rds.amazonaws.com"
      ]
    }
  }
}


resource "aws_iam_policy" "terraform_foundation" {
  name        = "cloudcontent-terraform-foundation"
  description = "Allows GitHub Actions to manage the CloudContent AWS foundation"

  policy = data.aws_iam_policy_document.terraform_foundation.json

  tags = {
    Name    = "cloudcontent-terraform-foundation"
    Project = "CloudContent"
  }
}

resource "aws_iam_role_policy_attachment" "terraform_foundation" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_foundation.arn
}