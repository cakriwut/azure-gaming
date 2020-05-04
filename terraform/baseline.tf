

resource "azurerm_resource_group" "streamer" {
   name = var.resource_group_name
   location  = var.location
   tags  = var.tags
}


resource "azurerm_virtual_network" "streamer" {
  name                  = "streamer-vnet"
  address_space         = ["10.0.0.0/16"]
  location              = azurerm_resource_group.streamer.location
  resource_group_name   = azurerm_resource_group.streamer.name
  tags                  = var.tags
}

resource "azurerm_subnet" "streamer" {
  name                  = "app-subnet"
  resource_group_name   = azurerm_resource_group.streamer.name
  virtual_network_name  = azurerm_virtual_network.streamer.name
  address_prefixes      = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "streamer" {
  name                  = "streamer-nsg"
  location              = var.location
  resource_group_name   = azurerm_resource_group.streamer.name

  security_rule {
      name                  = "RDP"
      priority              = 1001
      direction             = "Inbound"
      access                = "Allow"
      protocol              = "TCP"
      source_port_range     = "*"
      destination_port_range = "3389"
      source_address_prefix = "*"
      destination_address_prefix = "*"
  }

  tags  = var.tags
}


resource "azurerm_subnet_network_security_group_association" "streamer" {
  subnet_id                 = azurerm_subnet.streamer.id
  network_security_group_id = azurerm_network_security_group.streamer.id
}
