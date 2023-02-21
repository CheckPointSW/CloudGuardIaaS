# Check Point CloudGuard IaaS High Availability - Terraform Template

# --- Google Provider ---
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

# --- Check Point Deployment ---
variable "prefix" {
  type = string
  description = "(Optional) Resources name prefix"
  default = "chkp-tf-ha"
}
variable "license" {
  type = string
  description = "Checkpoint license (BYOL or PAYG)."
  default = "BYOL"
}
variable "image_name" {
  type = string
  description = "The High Availability (cluster) image name (e.g. check-point-r8040-gw-byol-cluster-123-456-v12345678). You can choose the desired cluster image value from: https://github.com/CheckPointSW/CloudGuardIaaS/blob/master/gcp/deployment-packages/ha-byol/images.py"
}

# --- Instances Configuration ---
data "google_compute_regions" "available_regions" {
}
variable "region" {
  type = string
  default = "us-central1"
}
variable "zoneA" {
  type = string
  description = "Member A Zone. The zone determines what computing resources are available and where your data is stored and used."
  default = "us-central1-a"
}
variable "zoneB" {
  type = string
  description = "Member B Zone."
  default = "us-central1-a"
}
variable "machine_type" {
  type = string
  description = "Machine types determine the specifications of your machines, such as the amount of memory, virtual cores, and persistent disk limits an instance will have."
  default = "n1-standard-4"
}
variable "disk_type" {
  type = string
  description = "Storage space is much less expensive for a standard Persistent Disk. An SSD Persistent Disk is better for random IOPS or streaming throughput with low latency."
  default = "SSD Persistent Disk"
}
variable "disk_size" {
  type = number
  description = "Disk size in GB - Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space."
  default = 100
}
variable "admin_SSH_key" {
  type = string
  description = "(Optional) The SSH public key for SSH authentication to the MIG instances. Leave this field blank to use all project-wide pre-configured SSH keys."
  default = ""
}
variable "enable_monitoring" {
  type = bool
  description = "Enable Stackdriver monitoring"
  default = false
}

# --- Check Point ---
variable "management_network" {
  type = string
  description = "Security Management Server address - The public address of the Security Management Server, in CIDR notation. VPN peers addresses cannot be in this CIDR block, so this value cannot be the zero-address."
  validation {
    condition = var.management_network != "0.0.0.0/0"
    error_message = "Var.management_network value cannot be the zero-address."
  }
}
variable "sic_key" {
  type = string
  description = "The Secure Internal Communication one time secret used to set up trust between the cluster object and the management server. At least 8 alpha numeric characters. If SIC is not provided and needed, a key will be automatically generated"
}
variable "generate_password" {
  type = bool
  description = "Automatically generate an administrator password."
  default = false
}
variable "allow_upload_download" {
  type = bool
  description = "Allow download from/upload to Check Point."
  default = false
}
variable "admin_shell" {
  type = string
  description = "Change the admin shell to enable advanced command line configuration."
  default = "/etc/cli.sh"
}
# --- Quick connect to Smart-1 Cloud ---
variable "smart_1_cloud_token_a" {
  type = string
  description ="(Optional) Smart-1 cloud token for member A to connect this Gateway to Check Point's Security Management as a Service"
  default = ""
}
variable "smart_1_cloud_token_b" {
  type = string
  description ="(Optional) Smart-1 cloud token for member B to connect this Gateway to Check Point's Security Management as a Service"
  default = ""
}

resource "null_resource" "validate_both_tokens" {
  count = (var.smart_1_cloud_token_a != "" && var.smart_1_cloud_token_b != "") || (var.smart_1_cloud_token_a == "" && var.smart_1_cloud_token_b == "") ? 0 : "To connect to Smart-1 Cloud, you must provide two tokens (one per member)"
}
resource "null_resource" "validate_different_tokens" {
  count = var.smart_1_cloud_token_a != "" && var.smart_1_cloud_token_a == var.smart_1_cloud_token_b ? "To connect to Smart-1 Cloud, you must provide two different tokens" : 0
}
# --- Networking ---
variable "cluster_network_cidr" {
  type = string
  description = "Cluster external subnet CIDR. If the variable's value is not empty double quotes, a new network will be created. The Cluster public IP will be translated to a private address assigned to the active member in this external network."
  default = "10.0.0.0/24"
}
variable "cluster_network_name" {
  type = string
  description = "Cluster external network ID in the chosen zone. The network determines what network traffic the instance can access.If you have specified a CIDR block at var.cluster_network_cidr, this network name will not be used."
  default = ""
}
variable "cluster_network_subnetwork_name" {
  type = string
  description = "Cluster subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.cluster_network_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = ""
}
variable "cluster_ICMP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for ICMP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty list to unable ICMP traffic."
  default = []
}
variable "cluster_TCP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for TCP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty list to unable TCP traffic."
  default = []
}
variable "cluster_UDP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for UDP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty list to unable UDP traffic."
  default = []
}
variable "cluster_SCTP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for SCTP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty list to unable SCTP traffic."
  default = []
}
variable "cluster_ESP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for ESP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty list to unable ESP traffic."
  default = []
}
variable "mgmt_network_cidr" {
  type = string
  description = "Management external subnet CIDR. If the variable's value is not empty double quotes, a new network will be created. The public IP used to manage each member will be translated to a private address in this external network"
  default = "10.0.1.0/24"
}
variable "mgmt_network_name" {
  type = string
  description = "Management network ID in the chosen zone. The network determines what network traffic the instance can access. If you have specified a CIDR block at var.mgmt_network_cidr, this network name will not be used. "
  default = ""
}
variable "mgmt_network_subnetwork_name" {
  type = string
  description = "Management subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.mgmt_network_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = ""
}
variable "mgmt_ICMP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for ICMP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty list to unable ICMP traffic."
  default = []
}
variable "mgmt_TCP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for TCP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty list to unable TCP traffic."
  default = []
}
variable "mgmt_UDP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for UDP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty list to unable UDP traffic."
  default = []
}
variable "mgmt_SCTP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for SCTP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty list to unable SCTP traffic."
  default = []
}
variable "mgmt_ESP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for ESP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty list to unable ESP traffic."
  default = []
}
variable "num_internal_networks" {
  type = number
  description = "A number in the range 1 - 6 of internal network interfaces."
  default = 1
}
resource "null_resource" "num_internal_networks_validation" {
  // Will fail if var.num_internal_networks is less than 1 or more than 6
  count = var.num_internal_networks >= 1 && var.num_internal_networks <= 6 ? 0 : "variable num_internal_networks must be a number between 1 and 6. Multiple network interfaces deployment is described in: https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk121637"
}
variable "internal_network1_cidr" {
  type = string
  description = "1st internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default = "10.0.2.0/24"
}
variable "internal_network1_name" {
  type = string
  description = "1st internal network ID in the chosen zone. The network determines what network traffic the instance can access. If you have specified a CIDR block at var.internal_network1_cidr, this network name will not be used. "
  default = ""
}
variable "internal_network1_subnetwork_name" {
  type = string
  description = "1st internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.internal_network1_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = ""
}
variable "internal_network2_cidr" {
  type = string
  description = "Used only if var.num_internal_networks is 2 or and above - 2nd internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default = ""
}
variable "internal_network2_name" {
  type = string
  description = "Used only if var.num_internal_networks is 2 or and above - 2nd internal network ID in the chosen zone. The network determines what network traffic the instance can access. If you have specified a CIDR block at var.internal_network2_cidr, this network name will not be used. "
  default = ""
}
variable "internal_network2_subnetwork_name" {
  type = string
  description = "Used only if var.num_internal_networks is 2 or and above - 2nd internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.internal_network2_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = ""
}
variable "internal_network3_cidr" {
  type = string
  description = "Used only if var.num_internal_networks is 3 or and above - 3rd internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default = ""
}
variable "internal_network3_name" {
  type = string
  description = "Used only if var.num_internal_networks is 3 or and above - 3rd internal network ID in the chosen zone. The network determines what network traffic the instance can access. If you have specified a CIDR block at var.internal_network3_cidr, this network name will not be used. "
  default = ""
}
variable "internal_network3_subnetwork_name" {
  type = string
  description = "Used only if var.num_internal_networks is 3 or and above - 3rd internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.internal_network3_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = ""
}
variable "internal_network4_cidr" {
  type = string
  description = "Used only if var.num_internal_networks is 4 or and above - 4th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default = ""
}
variable "internal_network4_name" {
  type = string
  description = "Used only if var.num_internal_networks is 4 or and above - 4th internal network ID in the chosen zone. The network determines what network traffic the instance can access. If you have specified a CIDR block at var.internal_network4_cidr, this network name will not be used. "
  default = ""
}
variable "internal_network4_subnetwork_name" {
  type = string
  description = "Used only if var.num_internal_networks is 4 or and above - 4th internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.internal_network4_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = ""
}
variable "internal_network5_cidr" {
  type = string
  description = "Used only if var.num_internal_networks is 5 or and above - 5th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default = ""
}
variable "internal_network5_name" {
  type = string
  description = "Used only if var.num_internal_networks is 5 or and above - 5th internal network ID in the chosen zone. The network determines what network traffic the instance can access. If you have specified a CIDR block at var.internal_network5_cidr, this network name will not be used. "
  default = ""
}
variable "internal_network5_subnetwork_name" {
  type = string
  description = "Used only if var.num_internal_networks is 5 or and above - 5th internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.internal_network5_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = ""
}
variable "internal_network6_cidr" {
  type = string
  description = "Used only if var.num_internal_networks equals 6 - 6th internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network."
  default = ""
}
variable "internal_network6_name" {
  type = string
  description = "Used only if var.num_internal_networks equals 6 - 6th internal network ID in the chosen zone. The network determines what network traffic the instance can access. If you have specified a CIDR block at var.internal_network6_cidr, this network name will not be used. "
  default = ""
}
variable "internal_network6_subnetwork_name" {
  type = string
  description = "Used only if var.num_internal_networks equals 6 - 6th internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.internal_network6_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
  default = ""
}