terraform {
  required_version = ">= 0.14.3"
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.115.0"
    }
  }
}