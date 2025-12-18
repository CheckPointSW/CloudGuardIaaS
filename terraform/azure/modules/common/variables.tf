//************** Basic config variables**************//
variable "resource_group_name" {
  description = "Azure Resource Group name to build into"
  type = string
}

variable "resource_group_id" {
  description = "Azure Resource Group ID to use."
  type = string
  default = ""
}

variable "location" {
  description = "The location/region where resources will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type = string
}
//************** Virtual machine instance variables **************
variable "admin_username" {
  description = "Administrator username of deployed VM. Due to Azure limitations 'notused' name can be used"
  type        = string
  default     = "notused"
}

variable "admin_password" {
  description = "Administrator password of deployed Virtual Machine. The password must meet the complexity requirements of Azure"
  type = string
}

variable "serial_console_password_hash" {
  description = "Optional parameter, used to enable serial console connection in case of SSH key as authentication type"
  type = string
}

variable "maintenance_mode_password_hash" {
  description = "Maintenance mode password hash, relevant only for R81.20 and higher versions"
  type = string
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."
  default = {}
}

variable "boot_diagnostics" {
  type        = bool
  description = "Enable or Disable boot diagnostics"
  default     = true
}

variable "storage_account_additional_ips" {
  type = list(string)
  description = "IPs/CIDRs that are allowed access to the Storage Account"
  default = []
  validation {
      condition = !contains(var.storage_account_additional_ips, "0.0.0.0") && can([for ip in var.storage_account_additional_ips: regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", ip)])
      error_message = "Invalid IPv4 address."
  }
}
locals {
  serial_console_ips_per_location = {
    "eastasia": [
        "4.145.74.168",
        "20.195.85.180",
        "20.195.85.181",
        "20.205.68.106",
        "20.205.68.107",
        "20.205.69.28",
        "23.97.88.117",
        "23.98.106.151"
      ],
      "southeastasia": [
        "4.145.74.168",
        "20.195.85.180",
        "20.195.85.181",
        "20.205.68.106",
        "20.205.68.107",
        "20.205.69.28",
        "23.97.88.117",
        "23.98.106.151"
      ],
      "australiacentral": [
        "4.198.45.55",
        "4.200.251.224",
        "20.167.131.228",
        "20.53.52.250",
        "20.53.53.224",
        "20.53.55.174",
        "20.70.222.112",
        "20.70.222.113",
        "68.218.123.133"
      ],
      "australiacentral2": [
        "4.198.45.55",
        "4.200.251.224",
        "20.167.131.228",
        "20.53.52.250",
        "20.53.53.224",
        "20.53.55.174",
        "20.70.222.112",
        "20.70.222.113",
        "68.218.123.133"
      ],
      "australiaeast": [
        "4.198.45.55",
        "4.200.251.224",
        "20.167.131.228",
        "20.53.52.250",
        "20.53.53.224",
        "20.53.55.174",
        "20.70.222.112",
        "20.70.222.113",
        "68.218.123.133"
      ],
      "australiasoutheast": [
        "4.198.45.55",
        "4.200.251.224",
        "20.167.131.228",
        "20.53.52.250",
        "20.53.53.224",
        "20.53.55.174",
        "20.70.222.112",
        "20.70.222.113",
        "68.218.123.133"
      ],
      "brazilsouth": [
        "20.206.0.192",
        "20.206.0.193",
        "20.206.0.194",
        "20.226.211.157",
        "108.140.5.172",
        "191.234.136.63",
        "191.238.77.232",
        "191.238.77.233"
      ],
      "brazilsoutheast": [
        "20.206.0.192",
        "20.206.0.193",
        "20.206.0.194",
        "20.226.211.157",
        "108.140.5.172",
        "191.234.136.63",
        "191.238.77.232",
        "191.238.77.233"
      ],
      "canadacentral": [
        "20.175.7.183",
        "20.48.201.78",
        "20.48.201.79",
        "20.220.7.246",
        "52.139.106.74",
        "52.139.106.75",
        "52.228.86.177",
        "52.242.40.90"
      ],
      "canadaeast": [
        "20.175.7.183",
        "20.48.201.78",
        "20.48.201.79",
        "20.220.7.246",
        "52.139.106.74",
        "52.139.106.75",
        "52.228.86.177",
        "52.242.40.90"
      ],
      "northeurope": [
        "4.210.131.60",
        "20.105.209.72",
        "20.105.209.73",
        "40.113.178.49",
        "52.146.137.65",
        "52.146.139.220",
        "52.146.139.221",
        "98.71.107.78"
      ],
      "westeurope": [
        "4.210.131.60",
        "20.105.209.72",
        "20.105.209.73",
        "40.113.178.49",
        "52.146.137.65",
        "52.146.139.220",
        "52.146.139.221",
        "98.71.107.78"
      ],
      "francecentral": [
        "20.111.0.244",
        "40.80.103.247",
        "51.138.215.126",
        "51.138.215.127",
        "52.136.191.8",
        "52.136.191.9",
        "52.136.191.10",
        "98.66.128.35"
      ],
      "francesouth": [
        "20.111.0.244",
        "40.80.103.247",
        "51.138.215.126",
        "51.138.215.127",
        "52.136.191.8",
        "52.136.191.9",
        "52.136.191.10",
        "98.66.128.35"
      ],
      "germanynorth": [
        "20.52.94.114",
        "20.52.94.115",
        "20.52.95.48",
        "20.113.251.155",
        "51.116.75.88",
        "51.116.75.89",
        "51.116.75.90",
        "98.67.183.186"
      ],
      "germanywestcentral": [
        "20.52.94.114",
        "20.52.94.115",
        "20.52.95.48",
        "20.113.251.155",
        "51.116.75.88",
        "51.116.75.89",
        "51.116.75.90",
        "98.67.183.186"
      ],
      "centralindia": [
        "4.187.107.68",
        "20.192.47.134",
        "20.192.47.135",
        "20.192.152.150",
        "20.192.152.151",
        "20.192.153.104",
        "20.207.175.96",
        "52.172.82.199",
        "98.70.20.180"
      ],
      "southindia": [
        "4.187.107.68",
        "20.192.47.134",
        "20.192.47.135",
        "20.192.152.150",
        "20.192.152.151",
        "20.192.153.104",
        "20.207.175.96",
        "52.172.82.199",
        "98.70.20.180"
      ],
      "westindia": [
        "4.187.107.68",
        "20.192.47.134",
        "20.192.47.135",
        "20.192.152.150",
        "20.192.152.151",
        "20.192.153.104",
        "20.207.175.96",
        "52.172.82.199",
        "98.70.20.180"
      ],
      "japaneast": [
        "20.18.7.188",
        "20.43.70.205",
        "20.89.12.192",
        "20.89.12.193",
        "20.189.194.100",
        "20.189.228.222",
        "20.189.228.223",
        "20.210.144.254"
      ],
      "japanwest": [
        "20.18.7.188",
        "20.43.70.205",
        "20.89.12.192",
        "20.89.12.193",
        "20.189.194.100",
        "20.189.228.222",
        "20.189.228.223",
        "20.210.144.254"
      ],
      "koreacentral": [
        "20.200.166.136",
        "20.200.194.238",
        "20.200.194.239",
        "20.200.196.96",
        "20.214.133.81",
        "52.147.119.28",
        "52.147.119.29",
        "52.147.119.30"
      ],
      "koreasouth": [
        "20.200.166.136",
        "20.200.194.238",
        "20.200.194.239",
        "20.200.196.96",
        "20.214.133.81",
        "52.147.119.28",
        "52.147.119.29",
        "52.147.119.30"
      ],
      "norwaywest": [
        "20.100.1.154",
        "20.100.1.155",
        "20.100.1.184",
        "20.100.21.182",
        "51.13.138.76",
        "51.13.138.77",
        "51.13.138.78",
        "51.120.183.54"
      ],
      "norwayeast": [
        "20.100.1.154",
        "20.100.1.155",
        "20.100.1.184",
        "20.100.21.182",
        "51.13.138.76",
        "51.13.138.77",
        "51.13.138.78",
        "51.120.183.54"
      ],
      "switzerlandnorth": [
        "20.199.207.188",
        "20.208.4.98",
        "20.208.4.99",
        "20.208.4.120",
        "20.208.149.229",
        "51.107.251.190",
        "51.107.251.191",
        "51.107.255.176"
      ],
      "switzerlandwest": [
        "20.199.207.188",
        "20.208.4.98",
        "20.208.4.99",
        "20.208.4.120",
        "20.208.149.229",
        "51.107.251.190",
        "51.107.251.191",
        "51.107.255.176"
      ],
      "uaecentral": [
        "20.38.141.5",
        "20.45.95.64",
        "20.45.95.65",
        "20.45.95.66",
        "20.203.93.198",
        "20.233.132.205",
        "40.120.87.50",
        "40.120.87.51"
      ],
      "uaenorth": [
        "20.38.141.5",
        "20.45.95.64",
        "20.45.95.65",
        "20.45.95.66",
        "20.203.93.198",
        "20.233.132.205",
        "40.120.87.50",
        "40.120.87.51"
      ],
      "uksouth": [
        "20.58.68.62",
        "20.58.68.63",
        "20.90.32.180",
        "20.90.132.144",
        "20.90.132.145",
        "51.104.30.169",
        "172.187.0.26",
        "172.187.65.53"
      ],
      "ukwest": [
        "20.58.68.62",
        "20.58.68.63",
        "20.90.32.180",
        "20.90.132.144",
        "20.90.132.145",
        "51.104.30.169",
        "172.187.0.26",
        "172.187.65.53"
      ],
      "swedencentral": [
        "20.91.100.236",
        "51.12.22.174",
        "51.12.22.175",
        "51.12.22.204",
        "51.12.72.222",
        "51.12.72.223",
        "51.12.73.92",
        "172.160.216.6"
      ],
      "swedensouth": [
        "20.91.100.236",
        "51.12.22.174",
        "51.12.22.175",
        "51.12.22.204",
        "51.12.72.222",
        "51.12.72.223",
        "51.12.73.92",
        "172.160.216.6"
      ],
      "centralus": [
        "4.149.249.197",
        "4.150.239.210",
        "20.14.127.175",
        "20.40.200.175",
        "20.45.242.18",
        "20.45.242.19",
        "20.45.242.20",
        "20.47.232.186",
        "20.51.21.252",
        "20.69.5.160",
        "20.69.5.161",
        "20.69.5.162",
        "20.83.222.100",
        "20.83.222.101",
        "20.83.222.102",
        "20.98.146.84",
        "20.98.146.85",
        "20.98.194.64",
        "20.98.194.65",
        "20.98.194.66",
        "20.168.188.34",
        "20.241.116.153",
        "52.159.214.194",
        "57.152.124.244",
        "68.220.123.194",
        "74.249.127.175",
        "74.249.142.218",
        "157.55.93.0",
        "168.61.232.59",
        "172.183.234.204",
        "172.191.219.35"
      ],
      "eastus2": [
        "4.149.249.197",
        "4.150.239.210",
        "20.14.127.175",
        "20.40.200.175",
        "20.45.242.18",
        "20.45.242.19",
        "20.45.242.20",
        "20.47.232.186",
        "20.51.21.252",
        "20.69.5.160",
        "20.69.5.161",
        "20.69.5.162",
        "20.83.222.100",
        "20.83.222.101",
        "20.83.222.102",
        "20.98.146.84",
        "20.98.146.85",
        "20.98.194.64",
        "20.98.194.65",
        "20.98.194.66",
        "20.168.188.34",
        "20.241.116.153",
        "52.159.214.194",
        "57.152.124.244",
        "68.220.123.194",
        "74.249.127.175",
        "74.249.142.218",
        "157.55.93.0",
        "168.61.232.59",
        "172.183.234.204",
        "172.191.219.35"
      ],
      "eastus": [
        "4.149.249.197",
        "4.150.239.210",
        "20.14.127.175",
        "20.40.200.175",
        "20.45.242.18",
        "20.45.242.19",
        "20.45.242.20",
        "20.47.232.186",
        "20.51.21.252",
        "20.69.5.160",
        "20.69.5.161",
        "20.69.5.162",
        "20.83.222.100",
        "20.83.222.101",
        "20.83.222.102",
        "20.98.146.84",
        "20.98.146.85",
        "20.98.194.64",
        "20.98.194.65",
        "20.98.194.66",
        "20.168.188.34",
        "20.241.116.153",
        "52.159.214.194",
        "57.152.124.244",
        "68.220.123.194",
        "74.249.127.175",
        "74.249.142.218",
        "157.55.93.0",
        "168.61.232.59",
        "172.183.234.204",
        "172.191.219.35"
      ],
      "northcentralus": [
        "4.149.249.197",
        "4.150.239.210",
        "20.14.127.175",
        "20.40.200.175",
        "20.45.242.18",
        "20.45.242.19",
        "20.45.242.20",
        "20.47.232.186",
        "20.51.21.252",
        "20.69.5.160",
        "20.69.5.161",
        "20.69.5.162",
        "20.83.222.100",
        "20.83.222.101",
        "20.83.222.102",
        "20.98.146.84",
        "20.98.146.85",
        "20.98.194.64",
        "20.98.194.65",
        "20.98.194.66",
        "20.168.188.34",
        "20.241.116.153",
        "52.159.214.194",
        "57.152.124.244",
        "68.220.123.194",
        "74.249.127.175",
        "74.249.142.218",
        "157.55.93.0",
        "168.61.232.59",
        "172.183.234.204",
        "172.191.219.35"
      ],
      "southcentralus": [
        "4.149.249.197",
        "4.150.239.210",
        "20.14.127.175",
        "20.40.200.175",
        "20.45.242.18",
        "20.45.242.19",
        "20.45.242.20",
        "20.47.232.186",
        "20.51.21.252",
        "20.69.5.160",
        "20.69.5.161",
        "20.69.5.162",
        "20.83.222.100",
        "20.83.222.101",
        "20.83.222.102",
        "20.98.146.84",
        "20.98.146.85",
        "20.98.194.64",
        "20.98.194.65",
        "20.98.194.66",
        "20.168.188.34",
        "20.241.116.153",
        "52.159.214.194",
        "57.152.124.244",
        "68.220.123.194",
        "74.249.127.175",
        "74.249.142.218",
        "157.55.93.0",
        "168.61.232.59",
        "172.183.234.204",
        "172.191.219.35"
      ],
      "westus2": [
        "4.149.249.197",
        "4.150.239.210",
        "20.14.127.175",
        "20.40.200.175",
        "20.45.242.18",
        "20.45.242.19",
        "20.45.242.20",
        "20.47.232.186",
        "20.51.21.252",
        "20.69.5.160",
        "20.69.5.161",
        "20.69.5.162",
        "20.83.222.100",
        "20.83.222.101",
        "20.83.222.102",
        "20.98.146.84",
        "20.98.146.85",
        "20.98.194.64",
        "20.98.194.65",
        "20.98.194.66",
        "20.168.188.34",
        "20.241.116.153",
        "52.159.214.194",
        "57.152.124.244",
        "68.220.123.194",
        "74.249.127.175",
        "74.249.142.218",
        "157.55.93.0",
        "168.61.232.59",
        "172.183.234.204",
        "172.191.219.35"
      ],
      "westus3": [
        "4.149.249.197",
        "4.150.239.210",
        "20.14.127.175",
        "20.40.200.175",
        "20.45.242.18",
        "20.45.242.19",
        "20.45.242.20",
        "20.47.232.186",
        "20.51.21.252",
        "20.69.5.160",
        "20.69.5.161",
        "20.69.5.162",
        "20.83.222.100",
        "20.83.222.101",
        "20.83.222.102",
        "20.98.146.84",
        "20.98.146.85",
        "20.98.194.64",
        "20.98.194.65",
        "20.98.194.66",
        "20.168.188.34",
        "20.241.116.153",
        "52.159.214.194",
        "57.152.124.244",
        "68.220.123.194",
        "74.249.127.175",
        "74.249.142.218",
        "157.55.93.0",
        "168.61.232.59",
        "172.183.234.204",
        "172.191.219.35"
      ],
      "westcentralus": [
        "4.149.249.197",
        "4.150.239.210",
        "20.14.127.175",
        "20.40.200.175",
        "20.45.242.18",
        "20.45.242.19",
        "20.45.242.20",
        "20.47.232.186",
        "20.51.21.252",
        "20.69.5.160",
        "20.69.5.161",
        "20.69.5.162",
        "20.83.222.100",
        "20.83.222.101",
        "20.83.222.102",
        "20.98.146.84",
        "20.98.146.85",
        "20.98.194.64",
        "20.98.194.65",
        "20.98.194.66",
        "20.168.188.34",
        "20.241.116.153",
        "52.159.214.194",
        "57.152.124.244",
        "68.220.123.194",
        "74.249.127.175",
        "74.249.142.218",
        "157.55.93.0",
        "168.61.232.59",
        "172.183.234.204",
        "172.191.219.35"
      ],
      "westus": [
        "4.149.249.197",
        "4.150.239.210",
        "20.14.127.175",
        "20.40.200.175",
        "20.45.242.18",
        "20.45.242.19",
        "20.45.242.20",
        "20.47.232.186",
        "20.51.21.252",
        "20.69.5.160",
        "20.69.5.161",
        "20.69.5.162",
        "20.83.222.100",
        "20.83.222.101",
        "20.83.222.102",
        "20.98.146.84",
        "20.98.146.85",
        "20.98.194.64",
        "20.98.194.65",
        "20.98.194.66",
        "20.168.188.34",
        "20.241.116.153",
        "52.159.214.194",
        "57.152.124.244",
        "68.220.123.194",
        "74.249.127.175",
        "74.249.142.218",
        "157.55.93.0",
        "168.61.232.59",
        "172.183.234.204",
        "172.191.219.35"
      ],
      "eastus2euap": [
        "4.149.249.197",
        "4.150.239.210",
        "20.14.127.175",
        "20.40.200.175",
        "20.45.242.18",
        "20.45.242.19",
        "20.45.242.20",
        "20.47.232.186",
        "20.51.21.252",
        "20.69.5.160",
        "20.69.5.161",
        "20.69.5.162",
        "20.83.222.100",
        "20.83.222.101",
        "20.83.222.102",
        "20.98.146.84",
        "20.98.146.85",
        "20.98.194.64",
        "20.98.194.65",
        "20.98.194.66",
        "20.168.188.34",
        "20.241.116.153",
        "52.159.214.194",
        "57.152.124.244",
        "68.220.123.194",
        "74.249.127.175",
        "74.249.142.218",
        "157.55.93.0",
        "168.61.232.59",
        "172.183.234.204",
        "172.191.219.35"
      ],
      "centraluseuap": [
        "4.149.249.197",
        "4.150.239.210",
        "20.14.127.175",
        "20.40.200.175",
        "20.45.242.18",
        "20.45.242.19",
        "20.45.242.20",
        "20.47.232.186",
        "20.51.21.252",
        "20.69.5.160",
        "20.69.5.161",
        "20.69.5.162",
        "20.83.222.100",
        "20.83.222.101",
        "20.83.222.102",
        "20.98.146.84",
        "20.98.146.85",
        "20.98.194.64",
        "20.98.194.65",
        "20.98.194.66",
        "20.168.188.34",
        "20.241.116.153",
        "52.159.214.194",
        "57.152.124.244",
        "68.220.123.194",
        "74.249.127.175",
        "74.249.142.218",
        "157.55.93.0",
        "168.61.232.59",
        "172.183.234.204",
        "172.191.219.35"
      ]
  }
  serial_console_ips = contains(keys(local.serial_console_ips_per_location),var.location) ? local.serial_console_ips_per_location[var.location] : []
  storage_account_ip_rules = concat(local.serial_console_ips, var.storage_account_additional_ips)
}
variable "vm_instance_identity_type" {
  description = "Managed Service Identity type"
  type = string
  default = "SystemAssigned"
}

variable "template_name"{
  description = "Template name. Should be defined according to deployment type(ha, vmss)"
  type = string
}

variable "template_version"{
  description = "Template name. Should be defined according to deployment type(e.g. ha, vmss)"
  type = string
}

variable "bootstrap_script" {
  description = "An optional script to run on the initial boot"
  type = string
  default = ""
}

variable "os_version"{
  description = "GAIA OS version"
  type = string
}

locals { // locals for 'os_version' allowed values
  os_version_allowed_values = [
    "R81",
    "R8110",
    "R8120",
    "R82"
  ]
  // will fail if [var.installation_type] is invalid:
  validate_os_version_value = index(local.os_version_allowed_values, var.os_version)
}

variable "installation_type"{
  description = "Installation type. Allowed values: cluster, vmss"
  type = string
}

locals { // locals for 'installation_type' allowed values
  installation_type_allowed_values = [
    "cluster",
    "vmss",
    "management",
    "standalone",
    "gateway",
    "mds-primary",
    "mds-secondary",
    "mds-logserver"
  ]
  // will fail if [var.installation_type] is invalid:
  validate_installation_type_value = index(local.installation_type_allowed_values, var.installation_type)
}

variable "number_of_vm_instances"{
  description = "Number of VM instances to deploy"
  type = string
}

variable "allow_upload_download" {
  description = "Allow upload/download to Check Point"
  type = bool
}

variable "is_blink" {
  description = "Define if blink image is used for deployment"
}

variable "vm_size" {
  description = "Specifies size of Virtual Machine"
  type = string
}

locals {// locals for  'vm_size' allowed values
  allowed_vm_sizes = ["Standard_DS2_v2", "Standard_DS3_v2", "Standard_DS4_v2", "Standard_DS5_v2", "Standard_F2s",
    "Standard_F4s", "Standard_F8s", "Standard_F16s", "Standard_D4s_v3", "Standard_D8s_v3",
    "Standard_D16s_v3", "Standard_D32s_v3", "Standard_D64s_v3", "Standard_E4s_v3", "Standard_E8s_v3",
    "Standard_E16s_v3", "Standard_E20s_v3", "Standard_E32s_v3", "Standard_E64s_v3", "Standard_E64is_v3",
    "Standard_F4s_v2", "Standard_F8s_v2", "Standard_F16s_v2", "Standard_F32s_v2", "Standard_F64s_v2",
    "Standard_M8ms", "Standard_M16ms", "Standard_M32ms", "Standard_M64ms", "Standard_M64s",
    "Standard_D2_v2", "Standard_D3_v2", "Standard_D4_v2", "Standard_D5_v2", "Standard_D11_v2",
    "Standard_D12_v2", "Standard_D13_v2", "Standard_D14_v2", "Standard_D15_v2", "Standard_F2",
    "Standard_F4", "Standard_F8", "Standard_F16", "Standard_D4_v3", "Standard_D8_v3", "Standard_D16_v3",
    "Standard_D32_v3", "Standard_D64_v3", "Standard_E4_v3", "Standard_E8_v3", "Standard_E16_v3",
    "Standard_E20_v3", "Standard_E32_v3", "Standard_E64_v3", "Standard_E64i_v3", "Standard_DS11_v2",
    "Standard_DS12_v2", "Standard_DS13_v2", "Standard_DS14_v2", "Standard_DS15_v2", "Standard_D2_v5", "Standard_D4_v5",
    "Standard_D8_v5", "Standard_D16_v5","Standard_D32_v5", "Standard_D2s_v5", "Standard_D4s_v5", "Standard_D8s_v5",
    "Standard_D16s_v5", "Standard_D2d_v5", "Standard_D4d_v5", "Standard_D8d_v5", "Standard_D16d_v5", "Standard_D32d_v5",
    "Standard_D2ds_v5", "Standard_D4ds_v5", "Standard_D8ds_v5", "Standard_D16ds_v5", "Standard_D32ds_v5"
  ]
  // will fail if [var.vm_size] is invalid:
  validate_vm_size_value = index(local.allowed_vm_sizes, var.vm_size)
}
variable "delete_os_disk_on_termination" {
  type        = bool
  description = "Delete datadisk when VM is terminated"
  default     = true
}

variable "publisher" {
  description = "CheckPoint publisher"
  default = "checkpoint"
}

//************** Storage image reference and plan variables ****************//
variable "vm_os_offer" {
  description = "The name of the image offer to be deployed.Choose from: check-point-cg-r81, check-point-cg-r8110, check-point-cg-r8120, check-point-cg-r82"
  type = string
}

locals { // locals for 'vm_os_offer' allowed values
  vm_os_offer_allowed_values = [
    "check-point-cg-r81",
    "check-point-cg-r8110",
    "check-point-cg-r8120",
    "check-point-cg-r82"
  ]
  // will fail if [var.vm_os_offer] is invalid:
  validate_os_offer_value = index(local.vm_os_offer_allowed_values, var.vm_os_offer)
  validate_os_version_match = regex(split("-", var.vm_os_offer)[3], lower(var.os_version))
}

variable "vm_os_sku" {
  /*
    Choose from:
      - "sg-byol"
      - "sg-ngtp" (for R81 and above)
      - "sg-ngtx" (for R81 and above)
      - "mgmt-byol"
      - "mgmt-25"
  */
  description = "The sku of the image to be deployed"
  type = string
}

locals { // locals for 'vm_os_sku' allowed values
  vm_os_sku_allowed_values = [
    "sg-byol",
    "sg-ngtp",
    "sg-ngtx",
    "mgmt-byol",
    "mgmt-25"
  ]
  // will fail if [var.vm_os_sku] is invalid:
  validate_vm_os_sku_value = index(local.vm_os_sku_allowed_values, var.vm_os_sku)
}

variable "vm_os_version" {
  description = "The version of the image that you want to deploy. "
  type = string
  default = "latest"
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options is Standard_LRS, Premium_LRS"
  type = string
  default     = "Standard_LRS"
}

locals { // locals for 'storage_account_type' allowed values
  storage_account_type_allowed_values = [
    "Standard_LRS",
    "Premium_LRS"
  ]
  // will fail if [var.storage_account_type] is invalid:
  validate_storage_account_type_value = index(local.storage_account_type_allowed_values, var.storage_account_type)
}

variable "storage_account_tier" {
  description = "Defines the Tier to use for this storage account.Valid options are Standard and Premium"
  default = "Standard"
}

locals { // locals for 'storage_account_tier' allowed values
  storage_account_tier_allowed_values = [
   "Standard",
   "Premium"
  ]
  // will fail if [var.storage_account_tier] is invalid:
  validate_storage_account_tier_value = index(local.storage_account_tier_allowed_values, var.storage_account_tier)
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account.Valid options are LRS, GRS, RAGRS and ZRS"
  type = string
  default = "LRS"
}

locals { // locals for 'account_replication_type' allowed values
  account_replication_type_allowed_values = [
   "LRS",
   "GRS",
   "RAGRS",
   "ZRS"
  ]
  // will fail if [var.account_replication_type] is invalid:
  validate_account_replication_type_value = index(local.account_replication_type_allowed_values, var.account_replication_type)
}

variable "disk_size" {
  description = "Storage data disk size size(GB). Select a number between 100 and 3995"
  type = string
}

resource "null_resource" "disk_size_validation" {
  // Will fail if var.disk_size is less than 100 or more than 3995
  count = tonumber(var.disk_size) >= 100 && tonumber(var.disk_size) <= 3995 ? 0 : "variable disk_size must be a number between 100 and 3995"
}

//************** Storage OS disk variables **************//
variable "storage_os_disk_create_option" {
  description = "The method to use when creating the managed disk"
  type = string
  default = "FromImage"
}

variable "storage_os_disk_caching" {
  description = "Specifies the caching requirements for the OS Disk"
  default = "ReadWrite"
}

variable "managed_disk_type" {
  description = "Specifies the type of managed disk to create. Possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS"
  type = string
  default     = "Standard_LRS"
}

locals { // locals for 'managed_disk_type' allowed values
  managed_disk_type_allowed_values = [
   "Standard_LRS",
   "Premium_LRS"
  ]
  // will fail if [var.managed_disk_type] is invalid:
  validate_managed_disk_type_value = index(local.managed_disk_type_allowed_values, var.managed_disk_type)
}

variable "authentication_type" {
  description = "Specifies whether a password authentication or SSH Public Key authentication should be used"
  type = string
}
locals { // locals for 'authentication_type' allowed values
  authentication_type_allowed_values = [
    "Password",
    "SSH Public Key"
  ]
  // will fail if [var.authentication_type] is invalid:
  validate_authentication_type_value = index(local.authentication_type_allowed_values, var.authentication_type)
}


//********************** Role Assignments variables**************************//
variable "role_definition" {
  description = "Role definition. The full list of Azure Built-in role descriptions can be found at https://docs.microsoft.com/bs-latn-ba/azure/role-based-access-control/built-in-roles"
  type = string
  default = "Contributor"
}