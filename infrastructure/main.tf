# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.20.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network and subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "vnet" {
  name                 = "${var.resource_group_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Sql"]

  delegation {
    name = "vnet-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Postgres flexible server
resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "${var.resource_group_name}-dbsrv"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "14"
  administrator_login    = var.db_username
  administrator_password = var.db_password
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  zone                   = "1"
}

# Postgres database
resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = "${var.resource_group_name}-database"
  server_id = azurerm_postgresql_flexible_server.db.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# App Service Plan
resource "azurerm_service_plan" "asp" {
  name                = "${var.resource_group_name}-asp"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Backend web app
resource "azurerm_linux_web_app" "backend" {
  name                      = "${var.resource_group_name}-app-backend"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
  service_plan_id           = azurerm_service_plan.asp.id
  virtual_network_subnet_id = azurerm_subnet.vnet.id

  https_only = false

  site_config {
    always_on     = true
    http2_enabled = true
    application_stack {
      python_version = 3.9
    }
  }

  app_settings = {
    DEPLOYMENT_BRANCH = "main"
  }
}

# Deployment source backend
resource "azurerm_app_service_source_control" "backend" {
  app_id        = azurerm_linux_web_app.backend.id
  use_local_git = true
}

# Frontend web app
resource "azurerm_linux_web_app" "frontend" {
  name                      = "${var.resource_group_name}-app-frontend"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
  service_plan_id           = azurerm_service_plan.asp.id
  virtual_network_subnet_id = azurerm_subnet.vnet.id

  https_only = false

  site_config {
    always_on     = true
    http2_enabled = true
    application_stack {
      python_version = 3.9
    }
  }

  app_settings = {
    DEPLOYMENT_BRANCH = "main"
  }
}

# Deployment source frontend
resource "azurerm_app_service_source_control" "frontend" {
  app_id        = azurerm_linux_web_app.frontend.id
  use_local_git = true
}
