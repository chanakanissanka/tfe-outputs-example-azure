resource "azurerm_resource_group" "example" {
  name     = "example-resources-b"
  location = "Australia East"
}

resource "azurerm_network_security_group" "example" {
  name                = "example-security-group-b"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network-b"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.200.0.0/22"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.200.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.200.2.0/24"
    security_group = azurerm_network_security_group.example.id
  }

  tags = {
    environment = "Production"
  }
}

#Peering 
resource "azurerm_virtual_network_peering" "dev-to-hub" {
  name                      = "dev-to-hub"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.example.name
  remote_virtual_network_id = data.tfe_outputs.azlz2.values.virtual_network_id #This is the place where you call other workspace outputs
  allow_forwarded_traffic   = true
  #use_remote_gateways       = true
}

resource "azurerm_virtual_network_peering" "hub-to-dev" {
  name                      = "hub-to-dev"
  resource_group_name       = data.tfe_outputs.azlz2.values.rg_name
  virtual_network_name      = data.tfe_outputs.azlz2.values.virtual_network_name
  remote_virtual_network_id = azurerm_virtual_network.example.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
}
