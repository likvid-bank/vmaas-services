terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.26.0"
    }
  }
}

provider "azurerm" {
  features {}

  # ARM_SUBSCRIPTION_ID
  # ARM_CLIENT_ID
  # ARM_CLIENT_SECRET
}
