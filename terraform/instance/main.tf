data "azurerm_subnet" "main" {
  name                 = "default"
  virtual_network_name = "vmaas"
  resource_group_name  = "vmaas"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name      = "internal"
    primary   = true
    subnet_id = data.azurerm_subnet.main.id

    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  size           = var.size
  admin_username = var.admin.username

  source_image_reference {
    publisher = var.source_image.publisher
    offer     = var.source_image.offer
    sku       = var.source_image.sku
    version   = var.source_image.version
  }

  network_interface_ids = [azurerm_network_interface.main.id]

  admin_ssh_key {
    username   = var.admin.username
    public_key = var.admin.ssh_public_key
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

resource "azurerm_managed_disk" "main" {
  count = var.storage > 0 ? 1 : 0

  name                = "${var.name}-data"
  location            = var.location
  resource_group_name = var.resource_group_name

  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.storage
}

resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  count = var.storage > 0 ? 1 : 0

  managed_disk_id    = azurerm_managed_disk.main[0].id
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  lun                = 0
  caching            = "ReadWrite"
}
