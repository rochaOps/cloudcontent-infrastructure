resource "aws_ssm_association" "ansible" {
  name = "AWS-ApplyAnsiblePlaybooks"
  # Manter desabilitada enquanto o artifact ZIP ainda não existe no S3.
  #  count = 0

  association_name = "${local.name_prefix}-ansible"

  targets {
    key = "tag:Lab"

    values = [
      "ansible-ec2-ssm",
    ]
  }

parameters = {
  SourceType          = "S3"
  SourceInfo          = jsonencode({
    path = "https://s3.amazonaws.com/${aws_s3_bucket.ansible_artifacts.bucket}/ansible/cloudcontent-ansible.zip"
  })
  InstallDependencies = "False"
  PlaybookFile        = "playbook.yml"
  ExtraVariables      = "SSM=True"
  Check               = "False"
  Verbose             = "-v"
}

  depends_on = [
    aws_iam_role_policy_attachment.ec2_ssm,
    aws_iam_role_policy_attachment.ec2_ansible_artifacts_read,
  ]
}