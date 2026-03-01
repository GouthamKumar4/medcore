# ──────────────────────────────────────────────────────────────
# MODULE: App Service — Variables
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
  description = "Short region code (cin = centralindia)"
  type        = string
  default     = "cin"
}

variable "resource_group_name" {
  description = "Resource group to deploy into"
  type        = string
}

variable "sku_name" {
  description = "App Service Plan SKU: B1 (dev), B2 (prod)"
  type        = string
  default     = "B1"
}

variable "always_on" {
  description = "Keep app running 24/7? true=prod, false=dev"
  type        = bool
  default     = false
}

variable "aspnet_environment" {
  description = "ASPNETCORE_ENVIRONMENT: Development or Production"
  type        = string
  default     = "Development"
}

variable "app_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
  default     = ""
}

variable "key_vault_uri" {
  description = "Key Vault URI for secret references"
  type        = string
  default     = ""
}

variable "sql_connection_string" {
  description = "SQL connection string"
  type        = string
  default     = ""
  sensitive   = true
}

variable "extra_app_settings" {
  description = "Additional app settings"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
