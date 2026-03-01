# ──────────────────────────────────────────────────────────────
# DEV ENVIRONMENT — Calls all modules with dev-specific settings
# ──────────────────────────────────────────────────────────────
# App Service: B1, always_on=false    | SQL: S0, 20GB, 7-day backup
# Key Vault: 7-day soft delete        | Logs: 30-day retention
# Cost: ~₹2,575/month
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
    key                  = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
  subscription_id = var.subscription_id
}

data "azurerm_client_config" "current" {}

locals {
  common_tags = {
    Application = "MedCore"
    Environment = var.environment
    ManagedBy   = "Terraform"
    CostCenter  = "IT-002"
    Owner       = "Platform Team"
  }
}

# ─── Monitoring (create first — others need its outputs) ───
module "monitoring" {
  source              = "../../modules/monitoring"
  project             = var.project
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  log_retention_days  = 30
  tags                = local.common_tags
}

# ─── Key Vault ───
module "key_vault" {
  source                   = "../../modules/key-vault"
  project                  = var.project
  environment              = var.environment
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sql_admin_password       = var.sql_admin_password
  soft_delete_days         = 7
  purge_protection         = false
  app_service_principal_id = module.app_service.principal_id
  tags                     = local.common_tags
}

# ─── SQL Database ───
module "sql" {
  source              = "../../modules/sql-database"
  project             = var.project
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  sql_admin_password  = var.sql_admin_password
  aad_admin_login     = var.aad_admin_login
  aad_admin_object_id = var.aad_admin_object_id
  sku_name            = "S0"
  max_size_gb         = 20
  zone_redundant      = false
  backup_retention_days = 7
  developer_ip        = var.developer_ip
  allow_azure_services = true
  tags                = local.common_tags
}

# ─── App Service (.NET 8) ───
module "app_service" {
  source                         = "../../modules/app-service"
  project                        = var.project
  environment                    = var.environment
  location                       = var.location
  resource_group_name            = var.resource_group_name
  sku_name                       = "B1"
  always_on                      = false
  aspnet_environment             = "Development"
  sql_connection_string          = module.sql.connection_string
  key_vault_uri                  = module.key_vault.key_vault_uri
  app_insights_connection_string = module.monitoring.app_insights_connection_string
  tags                           = local.common_tags
}

