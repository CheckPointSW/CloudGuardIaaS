variable "service_account_path" {
  type = string
  description = "User service account path in JSON format - From the service account key page in the Cloud Console choose an existing account or create a new one. Next, download the JSON key file. Name it something you can remember, store it somewhere secure on your machine, and supply the path to the location is stored."
  default = ""
}
variable "project" {
  type = string
  description = "Personal project id. The project indicates the default GCP project all of your resources will be created in."
  default = ""
}
variable "region" {
  type = string
  default = "us-central1"
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
    condition = contains(["R8110", "R8120" , "R81", "R82"], var.os_version)
    error_message = "Allowed values for os-version are 'R8110', 'R8120' , 'R81', 'R82'"
  }
}
variable "installation_type" {
  type = string
  description = "Installation type"
  default = "Gateway only"
  validation {
    condition = contains(["Gateway only" , "Management only" , "Manual Configuration" , "Gateway and Management (Standalone)"] , var.installation_type)
    error_message = "Allowed values for installationType are 'Gateway only' , 'Management only' , 'Manual Configuration' , 'Gateway and Management (Standalone)'"
  }
}
variable "license" {
  type = string
  description = "Checkpoint license (BYOL or PAYG)."
  default = "BYOL"
  validation {
    condition = contains(["BYOL" , "PAYG"] , var.license)
    error_message = "Allowed licenses are 'BYOL' , 'PAYG'"
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
variable "network_name" {
  type = string
  description = "The network determines what network traffic the instance can access"
  default = "default"
}
variable "subnetwork_name" {
  type = string
  description = "Assigns the instance an IPv4 address from the subnetwork’s range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = "default"
}
variable "network_cidr" {
  type = string
  description = "The range of external addresses that are owned by this network, only IPv4 is supported (e.g. \"10.0.0.0/8\" or \"192.168.0.0/16\")."
}
variable "TCP_traffic" {
  type = list(string)
  description = "Allow TCP traffic from the Internet"
  default = []
}
variable "ICMP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for ICMP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable ICMP traffic."
  default = []
}
variable "UDP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for UDP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable UDP traffic."
  default = []
}
variable "SCTP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for SCTP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable SCTP traffic."
  default = []
}
variable "ESP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for ESP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable ESP traffic."
  default = []
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
  type = bool
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
  description = "A number in the range 0 - 8 of internal network interfaces."
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
    error_message = "Allowed values for external_ip are 'static' , 'ephemeral' , 'none'"
  }
}
variable "internal_network1_cidr" {
  type = string
  description = "1st internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default = "10.0.2.0/24"
}
variable "internal_network1_name" {
  type = string
  description = "1st internal network ID in the chosen zone."
  default = ""
}
variable "internal_network1_subnetwork_name" {
  type = string
  description = "1st internal subnet ID in the chosen network."
  default = ""
}
variable "internal_network2_cidr" {
  type = string
  description = "Used only if var.num_additional_networks is 2 or and above - 2nd internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default = ""
}
variable "internal_network2_name" {
  type = string
  description = "2nd internal network ID in the chosen zone."
  default = ""
}
variable "internal_network2_subnetwork_name" {
  type = string
  description = "2nd internal subnet ID in the chosen network."
  default = ""
}
variable "internal_network3_cidr" {
  type = string
  description = "Used only if var.num_additional_networks is 3 or and above - 3rd internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default = ""
}
variable "internal_network3_name" {
  type = string
  description = "3rd internal network ID in the chosen zone."
  default = ""
}
variable "internal_network3_subnetwork_name" {
  type = string
  description = "3rd internal subnet ID in the chosen network."
  default = ""
}
variable "internal_network4_cidr" {
  type = string
  description = "Used only if var.num_additional_networks is 4 or and above - 4th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default = ""
}
variable "internal_network4_name" {
  type = string
  description = "4th internal network ID in the chosen zone."
  default = ""
}
variable "internal_network4_subnetwork_name" {
  type = string
  description = "4th internal subnet ID in the chosen network."
  default = ""
}
variable "internal_network5_cidr" {
  type = string
  description = "Used only if var.num_additional_networks is 5 or and above - 5th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default = ""
}
variable "internal_network5_name" {
  type = string
  description = "5th internal network ID in the chosen zone."
  default = ""
}
variable "internal_network5_subnetwork_name" {
  type = string
  description = "5th internal subnet ID in the chosen network."
  default = ""
}
variable "internal_network6_cidr" {
  type = string
  description = "Used only if var.num_additional_networks equals 6 - 6th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default = ""
}
variable "internal_network6_name" {
  type = string
  description = "6th internal network ID in the chosen zone."
  default = ""
}
variable "internal_network6_subnetwork_name" {
  type = string
  description = "6th internal subnet ID in the chosen network."
  default = ""
}
variable "internal_network7_cidr" {
  type = string
  description = "Used only if var.num_additional_networks equals 7 - 7th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default = ""
}
variable "internal_network7_name" {
  type = string
  description = "7th internal network ID in the chosen zone."
  default = ""
}
variable "internal_network7_subnetwork_name" {
  type = string
  description = "7th internal subnet ID in the chosen network."
  default = ""
}
variable "internal_network8_cidr" {
  type = string
  description = "Used only if var.num_additional_networks equals 8 - 8th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default = ""
}
variable "internal_network8_name" {
  type = string
  description = "8th internal network ID in the chosen zone."
  default = ""
}
variable "internal_network8_subnetwork_name" {
  type = string
  description = "8th internal subnet ID in the chosen network."
  default = ""
}
