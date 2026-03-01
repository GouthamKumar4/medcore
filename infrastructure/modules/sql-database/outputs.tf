# ──────────────────────────────────────────────────────────────
# MODULE: SQL Database — Outputs
# ──────────────────────────────────────────────────────────────

output "server_id" {
  description = "SQL Server resource ID"
  value       = azurerm_mssql_server.this.id
}

output "server_name" {
  description = "SQL Server name"
  value       = azurerm_mssql_server.this.name
}

output "server_fqdn" {
  description = "SQL Server FQDN"
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "database_id" {
  description = "SQL Database resource ID"
  value       = azurerm_mssql_database.this.id
}

output "database_name" {
  description = "SQL Database name"
  value       = azurerm_mssql_database.this.name
}

output "connection_string" {
  description = "ADO.NET connection string (MI-based, no password)"
  value       = "Server=tcp:${azurerm_mssql_server.this.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.this.name};Authentication=Active Directory Default;"
}
