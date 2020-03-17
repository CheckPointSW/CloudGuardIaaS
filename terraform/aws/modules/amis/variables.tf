variable "amis_url" {
  type = string
  description = "URL to amis.json"
  default = "https://s3.amazonaws.com/CloudFormationTemplate/amis.json"
}

data "http" "amis_json_http" {
  url = var.amis_url
}

data "aws_region" "current" {}
locals {
  region = data.aws_region.current.name
}

// --- Version & License ---
variable "version_license" {
  type = string
  description =  "Version and license"
}

