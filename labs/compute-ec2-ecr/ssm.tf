# This read fails at plan time if the requested tag has not been pushed yet.
data "aws_ecr_image" "app" {
  count           = var.enable_workload ? 1 : 0
  repository_name = aws_ecr_repository.app.name
  image_tag       = var.image_tag
}

resource "aws_ssm_association" "ansible" {
  count            = var.enable_workload ? 1 : 0
  name             = "AWS-ApplyAnsiblePlaybooks"
  association_name = "${local.name_prefix}-ansible"

  targets {
    key    = "InstanceIds"
    values = [aws_instance.app.id]
  }

  parameters = {
    SourceType = "S3"
    SourceInfo = jsonencode({
      path = "https://${aws_s3_bucket.ansible_artifacts.bucket}.s3.${var.aws_region}.amazonaws.com/${aws_s3_object.ansible.key}"
    })
    InstallDependencies = "False"
    PlaybookFile        = "playbook.yml"
    # The AWS document rejects colons in ExtraVariables; Ansible restores sha256:.
    ExtraVariables = join(" ", [
      "SSM=True",
      "aws_region=${var.aws_region}",
      "ecr_repository=${aws_ecr_repository.app.repository_url}",
      "image_sha256=${trimprefix(data.aws_ecr_image.app[0].image_digest, "sha256:")}",
    ])
    Check   = "False"
    Verbose = "-v"
  }

  # Runs immediately on creation/update and reconciles drift every 30 minutes.
  schedule_expression              = "rate(30 minutes)"
  wait_for_success_timeout_seconds = 900

  depends_on = [
    aws_iam_role_policy_attachment.ec2_ssm,
    aws_iam_role_policy_attachment.ec2_ansible_artifacts_read,
    aws_iam_role_policy_attachment.ec2_ecr_pull,
    aws_s3_object.ansible,
  ]
}
