# ──────────────────────────────────────────────────────────────
# MODULE: Monitoring
# ──────────────────────────────────────────────────────────────
# Creates: Log Analytics Workspace + Application Insights
# ──────────────────────────────────────────────────────────────

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${var.project}-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = "appi-${var.project}-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"

  tags = var.tags
}
