terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    cbs = {
      source  = "PureStorage-OpenConnect/cbs"
    }
  }
}

provider "azurerm" {
  features {}
  client_id = var.azure_client_id
  client_secret = var.azure_client_secret
  tenant_id = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

provider "cbs" {
}

resource "azurerm_resource_group" "azure_rg" {
  name     = format("%s%s", var.azure_resourcegroup, var.azure_location)
  location = var.azure_location
}

resource "azurerm_public_ip" "azure_nat_ip" {
  name                = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-NAT-IP")
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "cbs_nat_gateway" {
  name                    = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-NAT")
  location                = azurerm_resource_group.azure_rg.location
  resource_group_name     = azurerm_resource_group.azure_rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "cbs_pub_ip_association" {
  nat_gateway_id       = azurerm_nat_gateway.cbs_nat_gateway.id
  public_ip_address_id = azurerm_public_ip.azure_nat_ip.id
}

resource "azurerm_virtual_network" "cbs_virtual_network" {
  name                = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-VNET")
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "cbs_subnet_sys" {
  name                 = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-SUBNET-SYS")
  resource_group_name  = azurerm_resource_group.azure_rg.name
  virtual_network_name = azurerm_virtual_network.cbs_virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault"]
}
resource "azurerm_subnet" "cbs_subnet_mgmt" {
  name                 = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-SUBNET-MGMT")
  resource_group_name  = azurerm_resource_group.azure_rg.name
  virtual_network_name = azurerm_virtual_network.cbs_virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet" "cbs_subnet_repl" {
  name                 = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-SUBNET-REPL")
  resource_group_name  = azurerm_resource_group.azure_rg.name
  virtual_network_name = azurerm_virtual_network.cbs_virtual_network.name
  address_prefixes     = ["10.0.3.0/24"]
}
resource "azurerm_subnet" "cbs_subnet_iscsi" {
  name                 = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-SUBNET-ISCSI")
  resource_group_name  = azurerm_resource_group.azure_rg.name
  virtual_network_name = azurerm_virtual_network.cbs_virtual_network.name
  address_prefixes     = ["10.0.4.0/24"]
}
resource "azurerm_network_security_group" "cbs_network_security_group_sys" {
  name                = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-NSG-SYS")
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
}
resource "azurerm_subnet_network_security_group_association" "cbs_nsg_sys" {
  subnet_id                 = azurerm_subnet.cbs_subnet_sys.id
  network_security_group_id = azurerm_network_security_group.cbs_network_security_group_sys.id
}
resource "azurerm_network_security_group" "cbs_network_security_group_mgmt" {
  name                = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-NSG-MGMT")
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
}
resource "azurerm_subnet_network_security_group_association" "cbs_nsg_mgmt" {
  subnet_id                 = azurerm_subnet.cbs_subnet_mgmt.id
  network_security_group_id = azurerm_network_security_group.cbs_network_security_group_mgmt.id
}
resource "azurerm_network_security_group" "cbs_network_security_group_repl" {
  name                = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-NSG-REPL")
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
}
resource "azurerm_subnet_network_security_group_association" "cbs_nsg_repl" {
  subnet_id                 = azurerm_subnet.cbs_subnet_repl.id
  network_security_group_id = azurerm_network_security_group.cbs_network_security_group_repl.id
}
resource "azurerm_network_security_group" "cbs_network_security_group_iscsi" {
  name                = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-NSG-ISCSI")
  location            = azurerm_resource_group.azure_rg.location
  resource_group_name = azurerm_resource_group.azure_rg.name
}
resource "azurerm_subnet_network_security_group_association" "cbs_nsg_iscsi" {
  subnet_id                 = azurerm_subnet.cbs_subnet_iscsi.id
  network_security_group_id = azurerm_network_security_group.cbs_network_security_group_iscsi.id
}

resource "azurerm_network_security_rule" "cbs_nsg_sys_rule_out" {
  name                        = "cbs_sys_outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.azure_rg.name
  network_security_group_name = azurerm_network_security_group.cbs_network_security_group_sys.name
}
resource "azurerm_network_security_rule" "cbs_nsg_mgmt_rule_out" {
  name                        = "cbs_mgmt_outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.azure_rg.name
  network_security_group_name = azurerm_network_security_group.cbs_network_security_group_mgmt.name
}
resource "azurerm_network_security_rule" "cbs_nsg_mgmt_rule_in" {
  name                        = "cbs_mgmt_inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges      = ["22","80","443","8084"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.azure_rg.name
  network_security_group_name = azurerm_network_security_group.cbs_network_security_group_mgmt.name
}

resource "azurerm_network_security_rule" "cbs_nsg_repl_rule_out" {
  name                        = "cbs_repl_outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges      = ["8117","443"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.azure_rg.name
  network_security_group_name = azurerm_network_security_group.cbs_network_security_group_repl.name
}
resource "azurerm_network_security_rule" "cbs_nsg_iscsi_rule_in" {
  name                        = "cbs_iscsi_inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3260"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.azure_rg.name
  network_security_group_name = azurerm_network_security_group.cbs_network_security_group_iscsi.name
}

resource "azurerm_subnet_nat_gateway_association" "cbs_nat_gateway_association" {
  subnet_id      = azurerm_subnet.cbs_subnet_sys.id
  nat_gateway_id = azurerm_nat_gateway.cbs_nat_gateway.id
}
resource "azurerm_network_interface" "networkinterface" {
    name                = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-VM-INT")
    location            = azurerm_resource_group.azure_rg.location
    resource_group_name = azurerm_resource_group.azure_rg.name
    ip_configuration {
        name = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-VM-IP")
        subnet_id = azurerm_subnet.cbs_subnet_mgmt.id
        private_ip_address_allocation = var.azure_network_interface_ip_allocation
    }
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
    name                = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-VM")
    resource_group_name = azurerm_resource_group.azure_rg.name
    location            = azurerm_resource_group.azure_rg.location
    size                = var.azure_vm_size
    admin_username      = var.azure_vm_username
    admin_password      = var.azure_vm_password
    disable_password_authentication = false
    network_interface_ids = [
        azurerm_network_interface.networkinterface.id,
    ]
    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18_04-lts-gen2"
        version   = "latest"
    }
    boot_diagnostics {
    }
}
resource "cbs_array_azure" "azure_cbs" {

    array_name = format("%s%s%s", var.azure_resourcegroup, var.azure_location, "-CBS")
    location = azurerm_resource_group.azure_rg.location
    resource_group_name = azurerm_resource_group.azure_rg.name
    license_key = var.license_key
    log_sender_domain = var.log_sender_domain
    alert_recipients = var.alert_recipients
    array_model = var.array_model
    zone = var.zone
    virtual_network = azurerm_virtual_network.cbs_virtual_network.name

    management_subnet = azurerm_subnet.cbs_subnet_mgmt.name
    system_subnet = azurerm_subnet.cbs_subnet_sys.name
    iscsi_subnet = azurerm_subnet.cbs_subnet_iscsi.name
    replication_subnet = azurerm_subnet.cbs_subnet_repl.name

    management_resource_group = azurerm_resource_group.azure_rg.name
    system_resource_group = azurerm_resource_group.azure_rg.name
    iscsi_resource_group = azurerm_resource_group.azure_rg.name
    replication_resource_group = azurerm_resource_group.azure_rg.name

    jit_approval {
        approvers {
            groups = var.groups
        }
    }
}
output "azure_vm_ip" {
    value = azurerm_linux_virtual_machine.linux_vm.private_ip_address
}
output "cbs_mgmt_endpoint" {
    value = cbs_array_azure.azure_cbs.management_endpoint
}
output "cbs_mgmt_endpoint_ct0" {
    value = cbs_array_azure.azure_cbs.management_endpoint_ct0
}
output "cbs_mgmt_endpoint_ct1" {
    value = cbs_array_azure.azure_cbs.management_endpoint_ct1
}
output "cbs_repl_endpoint_ct0" {
    value = cbs_array_azure.azure_cbs.replication_endpoint_ct0
}
output "cbs_repl_endpoint_ct1" {
    value = cbs_array_azure.azure_cbs.replication_endpoint_ct1
}
output "cbs_iscsi_endpoint_ct0" {
    value = cbs_array_azure.azure_cbs.iscsi_endpoint_ct0
}
output "cbs_iscsi_endpoint_ct1" {
    value = cbs_array_azure.azure_cbs.iscsi_endpoint_ct1
}
