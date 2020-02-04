provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=1.36.1"

  subscription_id = "----"
  client_id       = "----"
  client_secret   = "----"
  tenant_id       = "----"
}

variable "location" {
  default = "westeurope"
}

# must match what was used in autoprov-cfg config
variable "sickey" {
  default = "----"
}

variable "admin_password" {
  default = "----"
}


variable "custom_image_name" {
  default = "Checkpoint-8010.90013.0233-image"
}

/*
variable "client_secret" {
  default = 
}
*/
