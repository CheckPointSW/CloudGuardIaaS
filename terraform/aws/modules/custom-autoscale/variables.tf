// Module: Auto Scaling group of workload servers

// --- Environment ---
variable "prefix" {
  type = string
  description = "(Optional) Instances name prefix"
  default = ""
    validation {
    condition     = length(var.prefix) <= 40
    error_message = "Prefix can not exceed 40 characters."
  }
}
variable "asg_name" {
  type = string
  description = "Autoscaling Group name"
  default = "Check-Point-Security-Gateway-AutoScaling-Group-tf"
  validation {
    condition     = length(var.asg_name) <= 100
    error_message = "Autoscaling Group name can not exceed 100 characters."
  }
}

// --- VPC Network Configuration ---
variable "vpc_id" {
  type = string
  description = "Select an existing VPC"
}
variable "servers_subnets" {
  type = list(string)
  description = "Provide at least 2 private subnet IDs in the chosen VPC, separated by commas (e.g. subnet-0d72417c,subnet-1f61306f,subnet-1061d06f)"
}

// --- EC2 Instances Configuration ---
variable "server_ami" {
  type = string
  description = "The Amazon Machine Image ID of a preconfigured web server (e.g. ami-0dc7dc63)"
}
variable "server_name" {
  type = string
  description = "AMI of the servers"
  default = "Server-tf"
}
variable "servers_instance_type" {
  type = string
  description = "The EC2 instance type for the web servers"
  default = "t3.micro"
}
module "validate_servers_instance_type" {
  source = "../common/instance_type"

  chkp_type = "server"
  instance_type = var.servers_instance_type
}
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instances"
}
variable "allocate_public_address" {
  type = bool
  description = "Allocate an elastic IP for each server"
  default = false
}

// --- Auto Scaling Configuration ---
variable "servers_min_group_size" {
  type = number
  description = "The minimal number of servers in the Auto Scaling group"
  default = 2
}
resource "null_resource" "servers_min_group_size_too_small" {
  // servers_min_group_size validation - resource will not be created if the size is smaller than 1
  count = var.servers_min_group_size >= 1 ? 0 : "servers_min_group_size must be at least 1"
}
variable "servers_max_group_size" {
  type = number
  description = "The maximal number of servers in the Auto Scaling group"
  default = 10
}
resource "null_resource" "servers_max_group_size_too_small" {
  // servers_max_group_size validation - resource will not be created if the size is smaller than 1
  count = var.servers_max_group_size >= 1 ? 0 : "servers_max_group_size must be at least 1"
}
variable "servers_target_groups" {
  type = string
  description = "(Optional) An optional list of Target Groups to associate with the Auto Scaling group (comma separated list of ARNs, without spaces)"
  default = ""
}
variable "deploy_internal_security_group" {
  type = bool
  description = "Select 'false' to use an existing Security group"
  default = true
}
variable "source_security_group" {
  type = string
  description = "The ID of Security Group from which access will be allowed to the instances in this Auto Scaling group"
  default = ""
}