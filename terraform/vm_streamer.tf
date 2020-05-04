# /* App Server */

resource "azurerm_public_ip" "streamer" {
 count                        = var.vm_straemer_to_create
 name                         = format("${var.vm_streamer_base_name}-public-ip-%02d",count.index)
 location                     = azurerm_resource_group.streamer.location
 resource_group_name          = azurerm_resource_group.streamer.name
 allocation_method            = "Static" 
 domain_name_label            = format("${var.vm_streamer_base_name}%02d",count.index)
 tags                         = var.tags
}

resource "azurerm_network_interface" "streamer" {
    count = var.vm_straemer_to_create
    name =  format("${var.vm_streamer_base_name}-nic-%02d",count.index)
    location = azurerm_resource_group.streamer.location
    resource_group_name = azurerm_resource_group.streamer.name

    ip_configuration {
        name = "${var.vm_streamer_base_name}-nic-config"
        subnet_id = azurerm_subnet.streamer.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.streamer[count.index].id
    }
    tags = var.tags
  
}

resource "azurerm_windows_virtual_machine" "streamer" {  
   count = var.vm_straemer_to_create
   name = format("${var.vm_streamer_base_name}-%02d",count.index)
   location = azurerm_resource_group.streamer.location
   resource_group_name = azurerm_resource_group.streamer.name
   network_interface_ids = [azurerm_network_interface.streamer[count.index].id]
   size = var.vm_streamer_size
   admin_username =  var.admin_username
   admin_password = var.admin_password

   custom_data = filebase64("..\\setup.ps1")

#    additional_unattend_content {
#         setting = "AutoLogon"
#         content = data.template_file.auto_logon.rendered
#    }

#    additional_unattend_content {
#         setting = "FirstLogonCommands"
#         content = data.template_file.first_logon_command.rendered
#    }

   source_image_reference {
       publisher = "MicrosoftWindowsServer"
       offer = "WindowsServer"
       sku = "2019-Datacenter"
       version = "latest"
   }

   os_disk {
       caching = "ReadWrite"
       storage_account_type = "Standard_LRS"
   }
}

resource "azurerm_virtual_machine_extension" "streamer-customscript" {
  count = var.vm_straemer_to_create
  name                 = "CustomScript"
  virtual_machine_id   = azurerm_windows_virtual_machine.streamer[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  
  protected_settings = jsonencode({
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"$env:AdminUser='${var.admin_username}'; $env:AdminPassword='${var.admin_password}'; copy-item c:\\AzureData\\CustomData.bin c:\\setup.ps1;& c:\\setup.ps1 -admin_username $env:AdminUser -admin_password $env:AdminPassword; exit 0;\""
  })

  tags = var.tags
}

# resource "azurerm_virtual_machine_extension" "streamer-bginfo" {
#   count = var.vm_straemer_to_create
#   name                 = "BGInfo"
#   virtual_machine_id = azurerm_windows_virtual_machine.streamer[count.index].id
#   publisher            = "Microsoft.Compute"
#   type                 = "BGInfo"
#   type_handler_version = "2.1"  
#   depends_on           = [azurerm_virtual_machine_extension.streamer-customscript]
# }
