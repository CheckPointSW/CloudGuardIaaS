variable "amis_url" {
  type = string
  description = "URL to amis.yaml"
  default = "https://cgi-cfts.s3.amazonaws.com/utils/amis.yaml"
}

data "http" "amis_yaml_http" {
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

