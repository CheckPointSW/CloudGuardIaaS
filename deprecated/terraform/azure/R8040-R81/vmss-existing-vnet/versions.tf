terraform {
  required_version = ">= 0.14.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.81.0"
    }
    random = {
      version = "~> 3.5.1"
    }
  }
}


