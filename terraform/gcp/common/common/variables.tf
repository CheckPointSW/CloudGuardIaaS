variable "installation_type" {
  type = string
  description = "Installation type"
  default = "Gateway only"
}
variable "os_version" {
  type = string
  description = "GAIA OS version"
  default = "R8120"
  validation {
    condition = contains(["R8110", "R8120" , "R82"], var.os_version)
    error_message = "Allowed values for os_version are 'R8110' , 'R8120', 'R82'"
  }
}
variable "image_name" {
  type = string
  description = "The single gateway and management image name"
}
locals {
  regex_validate_mgmt_image_name = "^check-point-${lower(var.os_version)}-[^(gw)].*[0-9]{3}-([0-9]{3,}|[a-z]+)-v[0-9]{8,}.*"
  regex_validate_gw_image_name = "^check-point-${lower(var.os_version)}-gw-.*[0-9]{3}-([0-9]{3,}|[a-z]+)-v[0-9]{8,}.*"
  regex_validate_image_name = contains(["Gateway only", "Cluster", "AutoScale"], var.installation_type) ? local.regex_validate_gw_image_name : local.regex_validate_mgmt_image_name
  regex_image_name = length(regexall(local.regex_validate_image_name, var.image_name)) > 0 ? 0 : "Variable [image_name] must be a valid Check Point image name of the correct version."
  index_image_name = index(["0"], local.regex_image_name)
}
variable "license" {
  type = string
  description = "Checkpoint license (BYOL or PAYG)."
  default = "BYOL"
}
locals {
    license_allowed_values = [
    "BYOL",
    "PAYG"]
  // will fail if [var.license] is invalid:
  validate_license = index(local.license_allowed_values, upper(var.license))
}
variable "admin_SSH_key" {
  type = string
  description = "(Optional) The SSH public key for SSH authentication to the template instances. Leave this field blank to use all project-wide pre-configured SSH keys."
  default = ""
}
locals {
  regex_valid_admin_SSH_key = "^(^$|ssh-rsa AAAA[0-9A-Za-z+/]+[=]{0,3})"
  // Will fail if var.admin_SSH_key is invalid
  regex_admin_SSH_key = length(regexall(local.regex_valid_admin_SSH_key, var.admin_SSH_key)) > 0 ? 0 : "Please enter a valid SSH public key or leave empty"
  index_admin_SSH_key = index(["0"], local.regex_admin_SSH_key)
}
variable "admin_shell" {
  type = string
  description = "Change the admin shell to enable advanced command line configuration."
  default = "/etc/cli.sh"
}
locals {
    admin_shell_allowed_values = [
    "/etc/cli.sh",
    "/bin/bash",
    "/bin/csh",
    "/bin/tcsh"]
  // Will fail if var.admin_shell is invalid
  validate_admin_shell = index(local.admin_shell_allowed_values, var.admin_shell)
}
variable "externalIP" {
  type = string
  description = "External IP address type"
  default = "static"
  validation {
    condition = contains(["static", "ephemeral", "none"], var.externalIP)
    error_message = "Invalid value for externalIP. Allowed values are 'static', 'ephemeral' or 'none'."
  }
}
locals {
  external_ip_allowed_values = [
    "static",
    "ephemeral",
    "none"
  ]
  validate_external_ip = index(local.external_ip_allowed_values, var.externalIP)
}

