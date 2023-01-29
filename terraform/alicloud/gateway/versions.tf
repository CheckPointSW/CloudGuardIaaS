terraform {
  required_version = ">= 0.14.3"
  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = "~> 1.196.0"
    }
  }
}
