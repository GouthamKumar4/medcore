# ──────────────────────────────────────────────────────────────
# MODULE: Azure Key Vault
# ──────────────────────────────────────────────────────────────
# Creates: Key Vault + RBAC + Stores SQL password as secret
# ──────────────────────────────────────────────────────────────

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                       = "kv-${var.project}-${var.environment}-${var.location_short}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = var.soft_delete_days
  purge_protection_enabled   = var.purge_protection

  tags = var.tags
}

# App Service System MI → read secrets
resource "azurerm_role_assignment" "app_secrets_reader" {
  count                = var.app_service_principal_id != "" ? 1 : 0
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.app_service_principal_id
}

# Current user (terraform runner) → manage secrets
resource "azurerm_role_assignment" "admin" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Store SQL admin password
resource "azurerm_key_vault_secret" "sql_admin_password" {
  count        = var.sql_admin_password != "" ? 1 : 0
  name         = "sql-admin-password"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [azurerm_role_assignment.admin]
}

