# Check Point CloudGuard IaaS Autoscaling - Terraform Template

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

# --- Check Point---
variable "template_version"{
  description = "Template version. It is reccomended to always use the latest template version"
  type = string
  default = "20201028"
}
variable "prefix" {
  type = string
  description = "(Optional) Resources name prefix"
  default = "chkp-tf-mig"
}
variable "license" {
  type = string
  description = "Checkpoint license (BYOL or PAYG)."
  default = "BYOL"
}
variable "image_name" {
  type = string
  description = "The autoscaling (MIG) image name (e.g. check-point-r8040-gw-byol-mig-123-456-v12345678). You can choose the desired mig image value from: https://github.com/CheckPointSW/CloudGuardIaaS/blob/master/gcp/deployment-packages/autoscale-byol/images.py"
}
variable "management_nic" {
  type = string
  description = "Management Interface - Autoscaling Security Gateways in GCP can be managed by an ephemeral public IP or using the private IP of the internal interface (eth1)."
  default = "Ephemeral Public IP (eth0)"
}
variable "management_name" {
  type = string
  description = "The name of the Security Management Server as appears in autoprovisioning configuration. (Please enter a valid Security Management name including ascii characters only)"
  default = "tf-checkpoint-management"
}
variable "configuration_template_name" {
  type = string
  description = "Specify the provisioning configuration template name (for autoprovisioning). (Please enter a valid autoprovisioing configuration template name including ascii characters only)"
  default = "tf-asg-autoprov-tmplt"
}
variable "admin_SSH_key" {
  type = string
  description = "(Optional) The SSH public key for SSH authentication to the MIG instances. Leave this field blank to use all project-wide pre-configured SSH keys."
  default = ""
}
variable "network_defined_by_routes" {
  type = bool
  description = "Set eth1 topology to define the networks behind this interface by the routes configured on the gateway."
  default = true
}
variable "admin_shell" {
  type = string
  description = "Change the admin shell to enable advanced command line configuration."
  default = "/etc/cli.sh"
}
variable "allow_upload_download" {
  type = bool
  description = "Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point"
  default = true
}

# --- Networking ---
data "google_compute_regions" "available_regions" {
}
variable "region" {
  type = string
  default = "us-central1"
}
variable "external_network_name" {
  type = string
  description = "The network determines what network traffic the instance can access"
}
variable "external_subnetwork_name" {
  type = string
  description = "Assigns the instance an IPv4 address from the subnetwork’s range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
}
variable "internal_network_name" {
  type = string
  description = "The network determines what network traffic the instance can access"
}
variable "internal_subnetwork_name" {
  type = string
  description = "Assigns the instance an IPv4 address from the subnetwork’s range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network."
}
variable "ICMP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for ICMP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable ICMP traffic."
  default = []
}
variable "TCP_traffic" {
  type = list(string)
  description = "(Optional) Source IP ranges for TCP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable TCP traffic."
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

# --- Instance Configuration ---
variable "machine_type" {
  type = string
  default = "n1-standard-4"
}
variable "cpu_usage" {
  type = number
  description = "Target CPU usage (%) - Autoscaling adds or removes instances in the group to maintain this level of CPU usage on each instance."
  default = 60
}
resource "null_resource" "cpu_usage_validation" {
  // Will fail if var.cpu_usage is less than 10 or more than 90
  count = var.cpu_usage >= 10 && var.cpu_usage <= 90 ? 0 : "variable cpu_usage must be a number between 10 and 90"
}
variable "instances_min_grop_size" {
  type = number
  description = "The minimal number of instances"
  default = 2
}
variable "instances_max_grop_size" {
  type = number
  description = "The maximal number of instances"
  default = 10
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
resource "null_resource" "disk_size_validation" {
  // Will fail if var.disk_size is less than 100 or more than 4096
  count = var.disk_size >= 100 && var.disk_size <= 4096 ? 0 : "variable disk_size must be a number between 100 and 4096"
}
variable "enable_monitoring" {
  type = bool
  description = "Enable Stackdriver monitoring"
  default = false
}