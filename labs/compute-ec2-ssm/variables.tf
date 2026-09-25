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
    "10.20.10.0/24"
  ]
}