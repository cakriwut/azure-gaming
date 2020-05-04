terraform {
    required_providers {
        azurerm = "~> 2.5"
        random = "~> 2.2"
        template = "~> 2.1"
    }

    /* Use Init.cmd from root. Use prepare.ps1 to create init.cmd */
    //backend "azurerm" {}
}

provider "azurerm" {
    version = "~> 2.5"
    features {}  
}

data "template_file" "auto_logon" {
    template = file("auto_logon.xml")

    vars = {
        admin_username = var.admin_username
        admin_password = var.admin_password
    }
}

data "template_file" "first_logon_command" {
    template = file("first_logon_cmd.xml")

    vars = {
        admin_username = var.admin_username
        admin_password = var.admin_password
    }
}