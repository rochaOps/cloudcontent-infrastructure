variable "aws_region" {
  description = "AWS Region used by CloudContent"
  type        = string
  default     = "ap-northeast-1"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "rochaOps"
}

variable "github_owner_id" {
  description = "Immutable GitHub owner ID"
  type        = string
  default     = "282101360"
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
  default     = "cloudcontent-infrastructure"
}

variable "github_repository_id" {
  description = "Immutable GitHub repository ID"
  type        = string
  default     = "1369956497"
}

variable "github_environment" {
  description = "GitHub Environment allowed to assume the deployment role"
  type        = string
  default     = "production"
}

variable "terraform_state_bucket" {
  description = "S3 bucket containing Terraform remote states"
  type        = string
  default     = "tf-state-915227020774"
}

variable "terraform_foundation_state_key" {
  description = "Remote state key for the CloudContent foundation"
  type        = string
  default     = "cloudcontent/foundation/terraform.tfstate"
}