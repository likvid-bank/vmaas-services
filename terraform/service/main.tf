locals {
  location = "West Europe"

  instance_root  = "../../instances"
  instance_files = fileset(local.instance_root, "*/instance.yml")
  instance_data  = [for f in local.instance_files : yamldecode(replace(file("${local.instance_root}/${f}"), " !<PlatformContext>", ""))]
  instances      = { for id in local.instance_data : id.serviceInstanceId => id }

  binding_files = fileset(local.instance_root, "*/bindings/*/binding.yml")
  binding_data  = [for f in local.binding_files : yamldecode(replace(file("${local.instance_root}/${f}"), " !<PlatformContext>", ""))]
  bindings      = { for bd in local.binding_data : bd.bindingId => bd }
}

# Note: Network setup should be part of a blueprint
resource "azurerm_virtual_network" "project" {
  for_each = {
    for k, v in local.bindings :
    v.context.project_id => split("/", v.bindResource.tenant_id)[4]...
    if !v.deleted && !local.instances[v.serviceInstanceId].deleted
  }

  name                = "${each.key}-vnet"
  resource_group_name = each.value[0]
  address_space       = ["10.0.0.0/16"]
  location            = local.location
}

resource "azurerm_subnet" "project" {
  for_each = azurerm_virtual_network.project

  name                 = "default"
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.name
  address_prefixes     = ["10.0.0.0/16"]
}

module "instance" {
  for_each = {
    for k, v in local.bindings :
    k => v
    if !v.deleted && !local.instances[v.serviceInstanceId].deleted
  }

  source = "../instance"

  resource_group_name = split("/", each.value.bindResource.tenant_id)[4]
  prefix              = each.value.context.project_id
  location            = local.location

  subnet_id = azurerm_subnet.project[each.value.context.project_id].id

  # from parameters
  name    = local.instances[each.value.serviceInstanceId].parameters.name
  size    = local.instances[each.value.serviceInstanceId].parameters.size
  storage = lookup(local.instances[each.value.serviceInstanceId].parameters, "storage", 0)

  admin = {
    username       = local.instances[each.value.serviceInstanceId].parameters.username
    ssh_public_key = local.instances[each.value.serviceInstanceId].parameters.ssh_public_key
  }

  source_image = {
    publisher = split(":", local.instances[each.value.serviceInstanceId].parameters.source_image_id)[0]
    offer     = split(":", local.instances[each.value.serviceInstanceId].parameters.source_image_id)[1]
    sku       = split(":", local.instances[each.value.serviceInstanceId].parameters.source_image_id)[2]
    version   = split(":", local.instances[each.value.serviceInstanceId].parameters.source_image_id)[3]
  }
}
