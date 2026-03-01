# ──────────────────────────────────────────────────────────────
# MODULE: Monitoring — Variables
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

variable "log_retention_days" {
  description = "Log retention: 30 (dev), 90 (prod)"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
