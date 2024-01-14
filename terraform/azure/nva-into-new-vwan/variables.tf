variable "authentication_method" {
  description = "Azure authentication method"
  type = string
  validation {
    condition     = contains(["Azure CLI", "Service Principal"], var.authentication_method)
    error_message = "Valid values for authentication_method are 'Azure CLI','Service Principal'"
  }
}

variable "subscription_id" {
  description = "Subscription ID"
  type = string
}

variable "tenant_id" {
  description = "Tenant ID"
  type = string
}

variable "client_id" {
  description = "Application ID(Client ID)"
  type = string
}

variable "client_secret" {
  description = "A secret string that the application uses to prove its identity when requesting a token. Also can be referred to as application password."
  type = string
}

variable "resource-group-name" {
  type    = string
  default = "managed-app-resource-group"
}

variable "location" {
  type    = string
  default = "westcentralus"
}

variable "vwan-name" {
  type    = string
  default = "tf-vwan-demo"
}

variable "vwan-hub-name" {
  type    = string
  default = "tf-vwan-hub-demo"
}

variable "vwan-hub-address-prefix" {
  type    = string
  default = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vwan-hub-address-prefix, 0))
    error_message = "Please provide a valid CIDR specification for the VWAN address space"
  }
}

variable "managed-app-name" {
  type    = string
  default = "tf-vwan-managed-app-nva-demo"
}

variable "nva-rg-name" {
  type    = string
  default = "tf-vwan-managed-app-rg-demo"
}

variable "nva-name" {
  type    = string
  default = "tf-vwan-nva"
}

variable "cloudguard-version" {
  type    = string
  default = "R81.10 - Pay As You Go (NGTP)"
  validation {
    condition     = contains(["R81.10 - Pay As You Go (NGTP)", "R81.20 - Pay As You Go (NGTP)", "R81.10 - Pay As You Go (NGTX)", "R81.20 - Pay As You Go (NGTX)"], var.cloudguard-version)
    error_message = "Valid values for CloudGuard version are 'R81.10 - Pay As You Go (NGTP)','R81.20 - Pay As You Go (NGTP)','R81.10 - Pay As You Go (NGTX)' and 'R81.20 - Pay As You Go (NGTX)'"
  }
}

variable "scale-unit" {
  type    = string
  default = "2"
  validation {
    condition     = contains(["2", "4", "10", "20", "30", "60", "80"], var.scale-unit)
    error_message = "Valid values for CloudGuard version are '2', '4', '10', '20', '30', '60', '80'"
  }
}

variable "bootstrap-script" {
  type    = string
  default = ""
}

variable "admin-shell" {
  type    = string
  default = "/etc/cli.sh"
  validation {
    condition     = contains(["/etc/cli.sh", "/bin/bash", "/bin/tcsh", "/bin/csh"], var.admin-shell)
    error_message = "Valid shells are '/etc/cli.sh', '/bin/bash', '/bin/tcsh', '/bin/csh'"
  }
}

variable "sic-key" {
  type      = string
  default   = ""
  sensitive = true
  validation {
    condition = can(regex("^[a-z0-9A-Z]{12,30}$", var.sic-key))
    error_message = "Only alphanumeric characters are allowed, and the value must be 12-30 characters long."
  }
}

variable "ssh-public-key" {
  type    = string
  default = ""
}

variable "bgp-asn" {
  type    = string
  default = "64512"
  validation {
    condition = tonumber(var.bgp-asn) >= 64512 && tonumber(var.bgp-asn) <= 65534 && !contains([65515, 65520], tonumber(var.bgp-asn))
    error_message = "Only numbers between 64512 to 65534 are allowed excluding 65515, 65520."
  }
}

variable "custom-metrics" {
  type    = string
  default = "yes"
  validation {
    condition     = contains(["yes", "no"], var.custom-metrics)
    error_message = "Valid options are string('yes' or 'no')"
  }
}

variable "routing-intent-internet-traffic" {
  default = "yes"
  validation {
    condition     = contains(["yes", "no"], var.routing-intent-internet-traffic)
    error_message = "Valid options are string('yes' or 'no')"
  }
}

variable "routing-intent-private-traffic" {
  default = "yes"
  validation {
    condition     = contains(["yes", "no"], var.routing-intent-private-traffic)
    error_message = "Valid options are string('yes' or 'no')"
  }
}

variable "smart1-cloud-token-a" {
  type    = string
  default = ""
}

variable "smart1-cloud-token-b" {
  type    = string
  default = ""
}

variable "smart1-cloud-token-c" {
  type    = string
  default = ""
}

variable "smart1-cloud-token-d" {
  type    = string
  default = ""
}

variable "smart1-cloud-token-e" {
  type    = string
  default = ""
}