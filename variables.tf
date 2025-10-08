variable "project_id" {
  description = "The GCP project ID"
  type        = string
  validation {
    condition     = var.project_id != "PROJECT_ID" && length(var.project_id) > 0
    error_message = "The 'project_id' variable must be set to a valid GCP project ID and should not be 'PROJECT_ID'."
  }
}

variable "github_org" {
  description = "The GitHub organization for which the Workload Identity Provider is set up"
  type        = string
  validation {
    condition     = var.github_org != "GITHUB_ORG" && length(var.github_org) > 0
    error_message = "The 'github_org' variable must be set to a valid GitHub organization and should not be 'GITHUB_ORG'."
  }
}

variable "workload_identity_pool_id" {
  description = "ID for the workload identity pool"
  type        = string
}

variable "workload_identity_provider" {
  description = "Name for the workload identity provider"
  type        = string
}

variable "workload_identity_provider_description" {
  description = "Description for the workload identity provider"
  type        = string
}

variable "default_repositories" {
  description = "Restrict to one or more GitHub repositories, if not overridden per service account."
  type        = list(string)
  default     = []
}

variable "service_accounts" {
  description = "Service accounts for impersonation by terrateam"
  type = list(object({
    name         = string
    description  = optional(string, "Terrateam service account")
    repositories = optional(list(string), [])
  }))
}
