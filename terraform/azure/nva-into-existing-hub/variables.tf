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
  default = "tf-managed-app-resource-group"
}

variable "location" {
  type    = string
  default = "westcentralus"
}

variable "managed-app-name" {
  type    = string
  default = "tf-vwan-managed-app-nva"
}

variable "vwan-hub-name" {
  type    = string
}

variable "vwan-hub-resource-group" {
  type    = string
}

variable "nva-rg-name" {
  type    = string
  default = "tf-vwan-nva-rg"
}

variable "nva-name" {
  type    = string
  default = "tf-vwan-nva"
}

variable "os-version" {
  description = "GAIA OS version"
  type = string
  default = "R8120"
  validation {
    condition = contains(["R8110", "R8120", "R82"], var.os-version)
    error_message = "Allowed values for os-version are 'R8110', 'R8120', 'R82'"
  }
}

variable "license-type" {
  type    = string
  default = "Security Enforcement (NGTP)"
  validation {
    condition     = contains(["Security Enforcement (NGTP)", "Full Package (NGTX + S1C)", "Full Package Premium (NGTX + S1C++)"], var.license-type)
    error_message = "Allowed values for License Type are 'Security Enforcement (NGTP)', 'Full Package (NGTX + S1C)', 'Full Package Premium (NGTX + S1C++)'"
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

variable "existing-public-ip" {
  type = string
  default = ""  
}

variable "new-public-ip" {
  type = string
  default = "no"
    validation {
    condition     = contains(["yes", "no"], var.new-public-ip)
    error_message = "Valid options are string('yes' or 'no')"
  }
}

locals{
  # Validate that new-public-ip is false when existing-public-ip is used
  is_both_params_used = length(var.existing-public-ip) > 0 && var.new-public-ip == "yes"
  validation_message_both = "Only one parameter of existing-public-ip or new-public-ip can be used"
  _ = regex("^$", (!local.is_both_params_used ? "" : local.validation_message_both))
}