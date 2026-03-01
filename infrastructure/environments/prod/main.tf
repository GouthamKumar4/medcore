# ──────────────────────────────────────────────────────────────
# PROD ENVIRONMENT — Same modules, production-grade settings
# ──────────────────────────────────────────────────────────────
# App Service: B2, always_on=true     | SQL: S2, 100GB, 35-day backup
# Key Vault: 90-day soft delete       | Logs: 90-day retention
# Cost: ~₹10,875/month
# ──────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-medcore-tfstate"
    storage_account_name = "stmedcoretfstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  subscription_id = var.subscription_id

  # Skip auto-registration — Plan MIs (Reader) and Deploy MIs (Contributor on RG)
  # don't have subscription-level Microsoft.XXX/register/action permission.
  # Cloud admin pre-registers needed providers. See: platform/scripts/01-cloud-admin-setup.ps1
  resource_provider_registrations = "none"
}

data "azurerm_client_config" "current" {}

locals {
  common_tags = {
    Application = "MedCore"
    Environment = var.environment
    ManagedBy   = "Terraform"
    CostCenter  = "IT-001"
    Owner       = "Platform Team"
  }
}

module "monitoring" {
  source              = "../../modules/monitoring"
  project             = var.project
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  log_retention_days  = 90
  tags                = local.common_tags
}

module "key_vault" {
  source                   = "../../modules/key-vault"
  project                  = var.project
  environment              = var.environment
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sql_admin_password       = var.sql_admin_password
  soft_delete_days         = 90
  purge_protection         = true
  app_service_principal_id = module.app_service.principal_id
  tags                     = local.common_tags
}

module "sql" {
  source              = "../../modules/sql-database"
  project             = var.project
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  sql_admin_password  = var.sql_admin_password
  aad_admin_login     = var.aad_admin_login
  aad_admin_object_id = var.aad_admin_object_id
  sku_name            = "S2"
  max_size_gb         = 100
  zone_redundant      = true
  backup_retention_days = 35
  developer_ip        = ""
  allow_azure_services = true
  tags                = local.common_tags
}

module "app_service" {
  source                         = "../../modules/app-service"
  project                        = var.project
  environment                    = var.environment
  location                       = var.location
  resource_group_name            = var.resource_group_name
  sku_name                       = "B2"
  always_on                      = true
  aspnet_environment             = "Production"
  sql_connection_string          = module.sql.connection_string
  key_vault_uri                  = module.key_vault.key_vault_uri
  app_insights_connection_string = module.monitoring.app_insights_connection_string
  tags                           = local.common_tags
}
