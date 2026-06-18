data "azurerm_resource_group" "target" {
  name = var.resource_group_name
}

data "azurerm_virtual_machine" "target" {
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.target.name
}

resource "azurerm_virtual_machine_extension" "deploy_app" {
  name                       = "${var.vm_name}-custom-script"
  virtual_machine_id         = data.azurerm_virtual_machine.target.id
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    script = base64encode(local.deploy_observability_script)
  })
}
