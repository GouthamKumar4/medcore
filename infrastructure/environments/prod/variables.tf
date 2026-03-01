# ──────────────────────────────────────────────────────────────
# PROD ENVIRONMENT — Variables
# ──────────────────────────────────────────────────────────────

variable "project" {
  description = "Project name"
  type        = string
  default     = "medcore"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "centralindia"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group (created by cloud admin)"
  type        = string
  default     = "rg-medcore-prod-cin"
}

variable "sql_admin_password" {
  description = "SQL admin password"
  type        = string
  sensitive   = true
}

variable "aad_admin_login" {
  description = "Azure AD admin display name for SQL"
  type        = string
}

variable "aad_admin_object_id" {
  description = "Azure AD admin object ID for SQL"
  type        = string
}
