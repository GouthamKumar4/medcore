# ──────────────────────────────────────────────────────────────
# MODULE: SQL Database — Variables
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

variable "sql_admin_username" {
  description = "SQL Server admin username"
  type        = string
  default     = "medcoreadmin"
}

variable "sql_admin_password" {
  description = "SQL Server admin password"
  type        = string
  sensitive   = true
}

variable "aad_admin_login" {
  description = "Azure AD admin display name"
  type        = string
}

variable "aad_admin_object_id" {
  description = "Azure AD admin object ID"
  type        = string
}

variable "sku_name" {
  description = "Database SKU: S0 (dev), S2 (prod)"
  type        = string
  default     = "S0"
}

variable "max_size_gb" {
  description = "Max database size in GB"
  type        = number
  default     = 20
}

variable "zone_redundant" {
  description = "Enable zone redundancy?"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Backup retention days: 7 (dev), 35 (prod)"
  type        = number
  default     = 7
}

variable "developer_ip" {
  description = "Developer public IP for SQL firewall (dev only)"
  type        = string
  default     = ""
}

variable "allow_azure_services" {
  description = "Allow Azure services to access SQL?"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
