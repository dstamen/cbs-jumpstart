variable "azure_resourcegroup" {
    type = string
}
variable "azure_location" {
    type = string
}
variable "azure_client_id" {
    type = string
}
variable "azure_client_secret" {
    type = string
    sensitive = true
}
variable "azure_subscription_id" {
    type = string
}
variable "azure_tenant_id" {
    type = string
}
variable "azure_network_interface_ip_allocation" {
    type = string
}
variable "azure_vm_size" {
    type = string
}
variable "azure_vm_username" {
    type = string
}
variable "azure_vm_password" {
    type = string
    sensitive = true
}
variable "zone" {
    type = number
}
variable "log_sender_domain" {
    type = string
}

variable "alert_recipients" {
    type = list(string)
}

variable "groups" {
    type = list(string)
}

variable "array_model" {
    type = string
}

variable "license_key" {
    type = string
}