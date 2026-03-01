# ──────────────────────────────────────────────────────────────
# MODULE: Key Vault — Variables
# ──────────────────────────────────────────────────────────────

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment: dev, test, prod"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "location_short" {
  description = "Short region code"
  type        = string
  default     = "cin"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "app_service_principal_id" {
  description = "App Service System MI principal ID"
  type        = string
  default     = ""
}

variable "sql_admin_password" {
  description = "SQL admin password to store as secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "soft_delete_days" {
  description = "Soft delete retention: 7 (dev), 90 (prod)"
  type        = number
  default     = 7
}

variable "purge_protection" {
  description = "Enable purge protection? false=dev, true=prod"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
