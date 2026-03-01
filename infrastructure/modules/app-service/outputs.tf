# ──────────────────────────────────────────────────────────────
# MODULE: App Service — Outputs
# ──────────────────────────────────────────────────────────────

output "app_service_id" {
  description = "App Service resource ID"
  value       = azurerm_linux_web_app.this.id
}

output "app_service_name" {
  description = "App Service name"
  value       = azurerm_linux_web_app.this.name
}

output "default_hostname" {
  description = "Default URL: https://app-medcore-dev-cin.azurewebsites.net"
  value       = azurerm_linux_web_app.this.default_hostname
}

output "principal_id" {
  description = "System MI principal ID — used to grant SQL + Key Vault access"
  value       = azurerm_linux_web_app.this.identity[0].principal_id
}

output "tenant_id" {
  description = "System MI tenant ID"
  value       = azurerm_linux_web_app.this.identity[0].tenant_id
}

output "service_plan_id" {
  description = "App Service Plan resource ID"
  value       = azurerm_service_plan.this.id
}
