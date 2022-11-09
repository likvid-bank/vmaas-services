terraform {
  backend "kubernetes" {
    namespace     = "unipipe-vmaas-likvid"
    secret_suffix = "network-state"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "e1c85eff-0a2c-4268-9b6c-7d2ff9ca9848"
}

resource "azurerm_resource_group" "main" {
  name     = "vmaas"
  location = "West Europe"
}

resource "azurerm_virtual_network" "main" {
  name                = "vmaas"
  address_space       = ["172.16.0.0/16"]
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["172.16.0.0/16"]
}
