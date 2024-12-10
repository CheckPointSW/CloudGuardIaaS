
variable "project" {
  type = string
  description = "Personal project id. The project indicates the default GCP project all of your resources will be created in."
  default = ""
  validation {
    condition = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project)) && length(var.project) >= 6 && length(var.project) <= 30
    error_message = "The project ID must be 6-30 characters long, start with a letter, and can only include lowercase letters, numbers, hyphenst and cannot end with a hyphen."
  }
}
variable "zone" {
  type = string
  description = "The zone determines what computing resources are available and where your data is stored and used"
  default = "us-central1-a"
}
variable "image_name" {
  type = string
  description = "The single gateway and management image name"
}
variable "os_version" {
  type = string
  description = "GAIA OS version"
  default = "R8120"
  validation {
    condition = contains(["R8110", "R8120", "R82"], var.os_version)
    error_message = "Allowed values for os-version are 'R8110', 'R8120', 'R82'"
  }
}
variable "installation_type" {
  type = string
  description = "Installation type and version"
  default = "Gateway only"
  validation {
    condition = contains(["Gateway only" , "Management only" , "Manual Configuration" , "Gateway and Management (Standalone)"] , var.installation_type)
    error_message = "Allowed values for installationType are 'Gateway only' , 'Management only' , 'Manual Configuration' , 'Gateway and Management (Standalone)'"
  }
}
variable "prefix" {
  type = string
  description = "(Optional) Resources name prefix"
  default = "chkp-single-tf-"
}
variable "machine_type" {
  type = string
  default = "n1-standard-4"
}
variable "network" {
  type = list(string)
  description = "The network determines what network traffic the instance can access"
  default = ["default"]
}
variable "subnetwork" {
  type = list(string)
  description = "Assigns the instance an IPv4 address from the subnetwork’s range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = ["default"]
}
variable "disk_type" {
  type = string
  description ="Disk type"
  default = "SSD Persistent Disk"
  validation {
    condition = contains(["SSD Persistent Disk" , "Standard Persistent Disk"] , var.disk_type)
    error_message = "Allowed values for diskType are : 'SSD Persistent Disk' , 'Standard Persistent Disk'"
  }
}
variable "disk_size" {
  type = number
  description ="Disk size in GB"
  default = 100
}
variable "generate_password" {
  type = bool
  description ="Automatically generate an administrator password	"
  default = false
}
variable "management_nic" {
  type = string
  description = "Management Interface - Gateways in GCP can be managed by an ephemeral public IP or using the private IP of the internal interface (eth1)."
  default = "Ephemeral Public IP (eth0)"
}
variable "allow_upload_download" {
  type = string
  description ="Allow download from/upload to Check Point"
  default = true
}
variable "enable_monitoring" {
  type = bool
  description ="Enable Stackdriver monitoring"
  default = false
}
variable "admin_shell" {
  type = string
  description = "Change the admin shell to enable advanced command line configuration."
  default = "/etc/cli.sh"
  validation {
    condition     = contains(["/etc/cli.sh", "/bin/bash", "/bin/tcsh", "/bin/csh"], var.admin_shell)
    error_message = "Valid shells are '/etc/cli.sh', '/bin/bash', '/bin/tcsh', '/bin/csh'"
  }
}
variable "admin_SSH_key" {
  type = string
  description = "(Optional) The SSH public key for SSH authentication to the template instances. Leave this field blank to use all project-wide pre-configured SSH keys."
  default = ""
}
variable "maintenance_mode_password_hash" {
  description = "Maintenance mode password hash, relevant only for R81.20 and higher versions"
  type = string
  default = ""
}
variable "sic_key" {
  type = string
  description ="The Secure Internal Communication one time secret used to set up trust between the single gateway object and the management server"
  default = ""
  validation {
    condition = can(regex("^[a-z0-9A-Z]{12,30}$", var.sic_key))
    error_message = "Only alphanumeric characters are allowed, and the value must be 12-30 characters long."
  }
}
variable "management_gui_client_network" {
  type = string
  description ="Allowed GUI clients	"
  default = "0.0.0.0/0"
}
variable "smart_1_cloud_token" {
  type = string
  description ="(Optional) Smart-1 cloud token to connect this Gateway to Check Point's Security Management as a Service"
  default = ""
}
variable "num_additional_networks" {
  type = number
  description ="Number of additional network interfaces"
  default = 0
  validation {
    condition = var.num_additional_networks >= 0 && var.num_additional_networks <= 8
    error_message = "The number of internal networks must be between 0 and 8."
  }
}
variable "external_ip" {
  type = string
  description = "External IP address type"
  default = "static"
  validation {
    condition = contains(["static", "ephemeral", "none"], var.external_ip)
    error_message = "Allowed values for externalIP are 'static' , 'ephemeral' , 'none'"
  }
}
variable "internal_network1_network" {
  type = list(string)
  description = "1st internal network ID in the chosen zone."
  default = []
}
variable "internal_network1_subnetwork" {
  type = list(string)
  description = "1st internal subnet ID in the chosen network."
  default = []
}
variable "internal_network2_network" {
  type = list(string)
  description = "2nd internal network ID in the chosen zone."
  default = []
}
variable "internal_network2_subnetwork" {
  type = list(string)
  description = "2nd internal subnet ID in the chosen network."
  default = []
}
variable "internal_network3_network" {
  type = list(string)
  description = "3rd internal network ID in the chosen zone."
  default = []
}
variable "internal_network3_subnetwork" {
  type = list(string)
  description = "3rd internal subnet ID in the chosen network."
  default = []
}
variable "internal_network4_network" {
  type = list(string)
  description = "4th internal network ID in the chosen zone."
  default = []
}
variable "internal_network4_subnetwork" {
  type = list(string)
  description = "4th internal subnet ID in the chosen network."
  default = []
}
variable "internal_network5_network" {
  type = list(string)
  description = "5th internal network ID in the chosen zone."
  default = []
}
variable "internal_network5_subnetwork" {
  type = list(string)
  description = "5th internal subnet ID in the chosen network."
  default = []
}
variable "internal_network6_network" {
  type = list(string)
  description = "6th internal network ID in the chosen zone."
  default = []
}
variable "internal_network6_subnetwork" {
  type = list(string)
  description = "6th internal subnet ID in the chosen network."
  default = []
}
variable "internal_network7_network" {
  type = list(string)
  description = "7th internal network ID in the chosen zone."
  default = []
}
variable "internal_network7_subnetwork" {
  type = list(string)
  description = "7th internal subnet ID in the chosen network."
  default = []
}
variable "internal_network8_network" {
  type = list(string)
  description = "8th internal network ID in the chosen zone."
  default = []
}
variable "internal_network8_subnetwork" {
  type = list(string)
  description = "8th internal subnet ID in the chosen network."
  default = []
}
