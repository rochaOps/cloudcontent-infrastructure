output "vpc_id" {
  description = "CloudContent VPC ID"
  value       = module.vpc.vpc_attributes.id
}

output "app_subnet_ids" {
  description = "Application subnet IDs"
  value       = local.app_subnet_ids
}

output "database_subnet_ids" {
  description = "Database subnet IDs"
  value       = local.database_subnet_ids
}

output "rds_endpoint" {
  description = "CloudContent PostgreSQL endpoint"
  value       = module.rds.db_instance_endpoint
}

output "rds_resource_id" {
  description = "RDS resource ID used by IAM database authentication"
  value       = module.rds.db_instance_resource_id
}

output "rds_master_secret_arn" {
  description = "Secrets Manager ARN containing the RDS master credentials"
  value       = module.rds.db_instance_master_user_secret_arn
}

output "free_content_bucket" {
  description = "S3 bucket containing free content"
  value       = aws_s3_bucket.free_content.bucket
}

output "premium_content_bucket" {
  description = "S3 bucket containing premium content"
  value       = aws_s3_bucket.premium_content.bucket
}

output "ecr_repository_urls" {
  description = "CloudContent ECR repository URLs"

  value = {
    api      = aws_ecr_repository.api.repository_url
    frontend = aws_ecr_repository.frontend.repository_url
  }
}

output "interface_vpc_endpoint_ids" {
  description = "Interface VPC endpoint IDs"

  value = {
    for name, endpoint in aws_vpc_endpoint.interface :
    name => endpoint.id
  }
}

output "s3_gateway_endpoint_id" {
  description = "S3 Gateway VPC endpoint ID"
  value       = aws_vpc_endpoint.s3.id
}