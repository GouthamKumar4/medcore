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

  # WHY resource_provider_registrations = "none"?
  # By default, azurerm tries to register ALL 45+ resource providers it supports
  # (Microsoft.AVS, Microsoft.Databricks, Microsoft.MachineLearningServices, etc.)
  # Registration = subscription-level write: Microsoft.XXX/register/action
  # Our Plan MIs (Reader on RG) don't have subscription-level write → 403 on all.
  # Our Deploy MIs (Contributor on RG) also don't have subscription-level write.
  # Solution: Skip auto-registration. Cloud admin pre-registers needed providers.
  # See: platform/scripts/01-cloud-admin-setup.ps1
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
  tags                     = local.common_tags
}

# App Service System MI → read Key Vault secrets
# WHY here and not in the key-vault module?
#   module.app_service.principal_id is unknown at plan time (SystemAssigned MI
#   only exists after apply). Terraform cannot evaluate count/for_each on
#   unknown values. By placing it here unconditionally (no count needed —
#   we always have both App Service and Key Vault), Terraform handles the
#   unknown principal_id as a normal attribute that gets resolved at apply.
resource "azurerm_role_assignment" "app_kv_secrets_reader" {
  scope                = module.key_vault.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.app_service.principal_id
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
