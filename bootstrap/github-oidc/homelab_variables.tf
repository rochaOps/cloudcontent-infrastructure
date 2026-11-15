variable "homelab_repository" {
  description = "GitHub repository of the Proxmox homelab"
  type        = string
  default     = "homelab-devops"
}

variable "homelab_repository_id" {
  description = "Immutable GitHub repository ID of the Proxmox homelab"
  type        = string
  default     = "1458466070"
}

variable "homelab_environment" {
  description = "GitHub Environment allowed to assume the homelab apply role"
  type        = string
  default     = "homelab"
}

variable "homelab_state_key" {
  description = "Remote state key for the homelab lab environment"
  type        = string
}
