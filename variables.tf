variable "aws_region" {
  description = "AWS Region used by CloudContent"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "Project name used for naming and tagging"
  type        = string
  default     = "CloudContent"
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks used by CloudContent application subnets"
  type        = list(string)

  default = [
    "10.20.10.0/24",
    "10.20.20.0/24"
  ]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks used by CloudContent database subnets"
  type        = list(string)

  default = [
    "10.20.110.0/24",
    "10.20.120.0/24"
  ]
}

variable "app_db_username" {
  description = "PostgreSQL user used by the CloudContent application"
  type        = string
  default     = "cloudcontent_app"
}

variable "alb_listener_port" {
  description = "HTTPS listener port used by the internal ALB"
  type        = number
  default     = 443
}

variable "app_port" {
  description = "Port exposed by the CloudContent application"
  type        = number
  default     = 8080
}