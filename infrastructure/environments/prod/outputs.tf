# ──────────────────────────────────────────────────────────────
# PROD ENVIRONMENT — Outputs
# ──────────────────────────────────────────────────────────────

output "app_service_url" {
  description = "App Service URL"
  value       = "https://${module.app_service.default_hostname}"
}

output "app_service_name" {
  description = "App Service name"
  value       = module.app_service.app_service_name
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN"
  value       = module.sql.server_fqdn
}

output "sql_database_name" {
  description = "SQL database name"
  value       = module.sql.database_name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.key_vault.key_vault_uri
}

output "app_insights_connection_string" {
  description = "App Insights connection string"
  value       = module.monitoring.app_insights_connection_string
  sensitive   = true
}
