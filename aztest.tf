provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "azure-architecture-rg"
  location = "East US"
}

resource "azurerm_storage_account" "storage" {
  name                     = "azurearchistorage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "images"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_eventgrid_topic" "eventgrid" {
  name                = "image-upload-events"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_cosmosdb_account" "cosmos" {
  name                = "azurearchicosmos"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  enable_free_tier    = true
  consistency_policy {
    consistency_level = "Session"
  }
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "imagedb"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
}

resource "azurerm_function_app" "function" {
  name                       = "image-processor-function"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_service_plan.appserviceplan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  os_type                    = "Linux"
  version                    = "~4"
  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }
}

resource "azurerm_cognitive_account" "vision" {
  name                = "computervisionapi"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "CognitiveServices"
  sku_name            = "F0"
}
