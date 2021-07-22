# See blog at https://davidstamen.com/2021/07/21/pure-cloud-block-store-on-azure-jump-start/ for more information on Azure Jump Start

#Azure Variables
azure_resourcegroup = "CBS-" #Prefix for Jump Start Deployment Resources
azure_location = "EASTUS" #Region see entries below
azure_client_id = "0000-0000-0000-0000" # Remove if using az login
azure_client_secret = "0000-0000-0000-0000" # Remove if using az login
azure_subscription_id = "0000-0000-0000-0000" # Remove if using az login
azure_tenant_id = "0000-0000-0000-0000" # Remove if using az login
azure_network_interface_ip_allocation = "Dynamic"
azure_vm_size = "Standard_B1s"
azure_vm_username = "cbs"
azure_vm_password = "MySecurePassword"

#CBS Variables
license_key = "0000-0000-0000-0000" #CBS License key from Pure1
log_sender_domain = "domain.com" #DNS Domain for Array
alert_recipients = ["user@domain.com"] #Email for Alerts
array_model = "V10MUR1" #Array Model
zone = 1 #Azure Zone
groups = ["CBS-JIT-GROUP"] #Group for JIT Approval

/* Current Supported Regions for CBS Terraform Deployment
Australia East	        AUSTRALIAEAST
Central US	            CENTRALUS
East US	                EASTUS
East US 2	            EASTUS2
North Europe	        NORTHEUROPE
West Europe	            WESTEUROPE
West US 2	            WESTUS2
*/