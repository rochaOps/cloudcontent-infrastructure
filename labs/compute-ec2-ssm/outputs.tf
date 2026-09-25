output "s3_gateway_endpoint_id" {
  description = "S3 Gateway VPC endpoint ID"
  value       = aws_vpc_endpoint.s3.id
}

output "interface_vpc_endpoint_ids" {
  description = "Interface VPC endpoint IDs"

  value = {
    for name, endpoint in aws_vpc_endpoint.interface :
    name => endpoint.id
  }
}

output "aws_instance" {
  description = "Instance's ID"
  value       = aws_instance.app.id
}