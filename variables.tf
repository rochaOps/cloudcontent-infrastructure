variable "name" {
  description = "Name of the CloudContent infrastructure"
  type        = string
  default     = "CloudContent"
}

variable "cidr_block" {
  description = "CIDR block for the CloudContent VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "rds_resource_id" {
  description = "RDS DB resource ID used by IAM database authentication"
  type        = string
}

variable "app_db_username" {
  description = "PostgreSQL user used by the CloudContent application"
  type        = string
  default     = "cloudcontent_app"
}