variable "prefix" {
  type = string
  description = "(Optional) Resources name prefix"
  default = "chkp-tf-ha"
}
variable "region" {
  type = string
  default = "us-central1"
}
variable "zoneA" {
  type = string
  default = "us-central1-a"
}
variable "zoneB" {
  type = string
  default = "us-central1-a"
}
variable "machine_type" {
  type = string
  description = "Machine types determine the specifications of your machines, such as the amount of memory, virtual cores, and persistent disk limits an instance will have."
  default = "n1-standard-4"
}
variable "disk_size" {
  type = number
  description = "Disk size in GB - Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space."
  default = 100
}
variable "disk_type" {
  type = string
  description = "Storage space is much less expensive for a standard Persistent Disk. An SSD Persistent Disk is better for random IOPS or streaming throughput with low latency."
  default = "SSD Persistent Disk"
}
variable "image_name" {
  type = string
  description = "The High Availability (cluster) image name (e.g. check-point-r8110-gw-byol-cluster-335-985-v20220126). You can choose the desired cluster image value from: https://github.com/CheckPointSW/CloudGuardIaaS/blob/master/gcp/deployment-packages/ha-byol/images.py"
}
variable "cluster_network" {
  type = list(string)
  description = "Cluster external network ID in the chosen zone."
}
variable "cluster_network_subnetwork" {
  type = list(string)
  description = "Cluster subnet ID in the chosen network."
}
variable "mgmt_network" {
  type = list(string)
  description = "Management network ID in the chosen zone."
}
variable "mgmt_network_subnetwork" {
  type = list(string)
  description = "Management subnet ID in the chosen network."
}
variable "num_internal_networks" {
  type = number
  description = "A number in the range 1 - 6 of internal network interfaces."
  default = 1
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
variable "admin_SSH_key" {
  type = string
  description = "(Optional) The SSH public key for SSH authentication to the MIG instances. Leave this field blank to use all project-wide pre-configured SSH keys."
  default = ""
}
variable "project" {
  type = string
  description = "Personal project id. The project indicates the default GCP project all of your resources will be created in."
  default = ""
}
variable "generate_password" {
  type = bool
  description = "Automatically generate an administrator password."
  default = false
}
variable "sic_key" {
  type = string
  description = "The Secure Internal Communication one time secret used to set up trust between the cluster object and the management server. At least 8 alpha numeric characters. If SIC is not provided and needed, a key will be automatically generated"
}
variable "allow_upload_download" {
  type = bool
  description = "Allow download from/upload to Check Point."
  default = false
}
variable "enable_monitoring" {
  type = bool
  description = "Enable Stackdriver monitoring"
  default = false
}
variable "admin_shell" {
  type = string
  description = "Change the admin shell to enable advanced command line configuration."
  default = "/etc/cli.sh"
}
variable "smart1CloudTokenA" {
  type = string
  description ="(Optional) Smart-1 cloud token for member A to connect this Gateway to Check Point's Security Management as a Service"
  default = ""
}
variable "smart1CloudTokenB" {
  type = string
  description ="(Optional) Smart-1 cloud token for member B to connect this Gateway to Check Point's Security Management as a Service"
  default = ""
}
variable "management_network" {
  type = string
  description = "Security Management Server address - The public address of the Security Management Server, in CIDR notation. VPN peers addresses cannot be in this CIDR block, so this value cannot be the zero-address."
}
variable "generated_admin_password" {
  type = string
  description = "administrator password"
}
variable "primary_cluster_address_name" {
  type = string
}
variable "secondary_cluster_address_name" {
  type = string
}