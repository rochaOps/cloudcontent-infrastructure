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

variable "vpc_cidr" {
  description = "CIDR of the isolated lab VPC"
  type        = string
  default     = "10.30.0.0/16"
}

variable "app_subnet_cidrs" {
  description = "One private application subnet in the first AZ"
  type        = list(string)
  default     = ["10.30.10.0/24"]

  validation {
    condition     = length(var.app_subnet_cidrs) == 1
    error_message = "This lab uses exactly one private subnet."
  }
}

variable "enable_workload" {
  description = "Enable the SSM association after pushing the image and checking bootstrap"
  type        = bool
  default     = false
}

variable "image_tag" {
  description = "Existing ECR image tag resolved to a digest when the workload is enabled"
  type        = string
  default     = "lab"

  validation {
    condition     = can(regex("^[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}$", var.image_tag))
    error_message = "Provide a valid Docker image tag (1 to 128 characters)."
  }
}
