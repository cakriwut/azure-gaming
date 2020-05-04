variable "resource_group_name" {
   description = "Resource Group name for this deployment"  
}

variable "location" {
   description = "Deployment location, the region such as southeastasia, westus, etc."
}

variable "tags" {
    description = "Deployment tags"
    type        = map(string)
}

variable "vm_streamer_size" {
   description = "VM size"
}

variable "vm_straemer_to_create" {
   description = "Total VM to create"
}

variable "vm_streamer_base_name" {
   description = "Base VM Name"
}



variable "admin_username" {
    description = "User"
}

variable "admin_password" {
    description = "Password"
}