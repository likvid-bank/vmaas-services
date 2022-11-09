provider "azurerm" {
  features {}

  # ARM_SUBSCRIPTION_ID
  # ARM_CLIENT_ID
  # ARM_CLIENT_SECRET
}

module "vmaas" {
  source = "../instance"

  resource_group_name = split("/", var.tenant_id)[4]
  prefix              = var.project_id

  # from parameters
  name = var.name
  size = var.size

  admin = {
    username       = var.username
    ssh_public_key = var.ssh_public_key
  }

  source_image = {
    publisher = split(":", var.source_image_id)[0]
    offer     = split(":", var.source_image_id)[1]
    sku       = split(":", var.source_image_id)[2]
    version   = split(":", var.source_image_id)[3]
  }

  storage = var.storage
}
