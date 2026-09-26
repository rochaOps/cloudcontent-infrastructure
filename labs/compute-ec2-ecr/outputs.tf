output "aws_region" {
  description = "Region used by this lab"
  value       = var.aws_region
}

output "vpc_id" {
  description = "Isolated lab VPC ID"
  value       = module.vpc.vpc_attributes.id
}

output "instance_id" {
  description = "Private EC2 instance managed through SSM"
  value       = aws_instance.app.id
}

output "app_security_group_id" {
  description = "EC2 security group with no inbound rules"
  value       = aws_security_group.app.id
}

output "s3_gateway_endpoint_id" {
  description = "S3 Gateway endpoint for artifacts, packages and image layers"
  value       = aws_vpc_endpoint.s3.id
}

output "interface_vpc_endpoint_ids" {
  description = "Private SSM and ECR endpoints"
  value       = { for name, endpoint in aws_vpc_endpoint.interface : name => endpoint.id }
}

output "ecr_repository_url" {
  description = "Application image repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  description = "Application image repository name"
  value       = aws_ecr_repository.app.name
}

output "ansible_artifacts_bucket" {
  description = "Private bucket containing the Ansible bundle"
  value       = aws_s3_bucket.ansible_artifacts.bucket
}

output "ansible_artifact_key" {
  description = "Content-addressed Ansible bundle key"
  value       = aws_s3_object.ansible.key
}

output "association_id" {
  description = "SSM association ID; null until enable_workload is true"
  value       = try(aws_ssm_association.ansible[0].association_id, null)
}

output "deployed_image" {
  description = "Desired immutable image reference used by Ansible"
  value       = var.enable_workload ? "${aws_ecr_repository.app.repository_url}@${data.aws_ecr_image.app[0].image_digest}" : null
}
