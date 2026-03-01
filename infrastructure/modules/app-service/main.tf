# ──────────────────────────────────────────────────────────────
# MODULE: App Service
# ──────────────────────────────────────────────────────────────
# Creates: App Service Plan + App Service (Linux, .NET 8)
#
# WHY a module?
#   Dev calls this with sku=B1, instances=1
#   Prod calls this with sku=B2, instances=2
#   Same code, different parameters
# ──────────────────────────────────────────────────────────────

resource "azurerm_service_plan" "this" {
  name                = "asp-${var.project}-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name

  tags = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                = "app-${var.project}-${var.environment}-${var.location_short}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }

    minimum_tls_version = "1.2"
    always_on           = var.always_on
    health_check_path   = "/health"
  }

  app_settings = merge(
    {
      "ASPNETCORE_ENVIRONMENT"                = var.aspnet_environment
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
      "KeyVaultUri"                           = var.key_vault_uri
    },
    var.extra_app_settings
  )

  dynamic "connection_string" {
    for_each = toset(var.sql_connection_string != "" ? ["enabled"] : [])
    content {
      name  = "DefaultConnection"
      type  = "SQLAzure"
      value = var.sql_connection_string
    }
  }

  tags = var.tags
}
