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
  default     = "10.40.0.0/16"
}

variable "app_subnet_cidrs" {
  description = "One private application subnet in the first AZ"
  type        = list(string)
  default     = ["10.40.10.0/24"]

  validation {
    condition     = length(var.app_subnet_cidrs) == 1
    error_message = "This lab uses exactly one private subnet."
  }
}

variable "enable_workload" {
  description = "Enable the SSM association and desired digest parameter after first pipeline publication"
  type        = bool
  default     = false
}

variable "oidc_provider_arn" {
  description = "Existing GitHub OIDC provider; reuse bootstrap/github-oidc"
  type        = string
}
variable "publish_subject" {
  description = "Exact GitHub OIDC sub for main, including immutable IDs if enabled"
  type        = string
  validation {
    condition     = startswith(var.publish_subject, "repo:") && endswith(var.publish_subject, ":ref:refs/heads/main") && !strcontains(var.publish_subject, "*")
    error_message = "Use the exact repository subject restricted to refs/heads/main."
  }
}
variable "deploy_subject" {
  description = "Exact OIDC sub for the protected cloudcontent-lab environment"
  type        = string
  validation {
    condition     = startswith(var.deploy_subject, "repo:") && endswith(var.deploy_subject, ":environment:cloudcontent-lab") && !strcontains(var.deploy_subject, "*")
    error_message = "Use the exact repository subject for environment cloudcontent-lab."
  }
}
variable "initial_image_digest" {
  description = "Digest from the first pipeline publication; required when enable_workload is true"
  type        = string
  default     = null
  validation {
    condition     = var.initial_image_digest == null ? true : can(regex("^sha256:[a-f0-9]{64}$", var.initial_image_digest))
    error_message = "Use a real sha256 digest from the existing ECR repository."
  }
}
variable "parameter_name" {
  type    = string
  default = "/cloudcontent/compute-ec2-ecr-cicd/image-digest"
  validation {
    condition     = can(regex("^/[A-Za-z0-9_/-]+$", var.parameter_name))
    error_message = "Use an absolute SSM parameter path without spaces or colons."
  }
}
