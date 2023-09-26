terraform {
  required_version = ">= 0.14.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.24.1"
    }
  }
}
