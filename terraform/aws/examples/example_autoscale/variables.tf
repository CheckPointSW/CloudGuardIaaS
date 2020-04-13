variable "region" {
  type = string
  description = "AWS region"
  default = "us-east-1"
}
data "aws_region" "current" {
  name = var.region
}

// --- Environment ---
variable "prefix" {
  type = string
  description = "Environment prefix - prefix will be added to the autoscaling group and its instances' name"
  default = ""
}
variable "asg_name" {
  type = string
  description = "Autoscaling Group name"
  default = "CP-ASG-tf"
}

// --- VPC Network Configuration ---
variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
  description = "List of subnet IDs to launch resources into. Recommended at least 2"
}

// --- Automatic Provisioning with Security Management Server Settings ---
variable "gateways_provision_address_type" {
  type = string
  description = "Determines if the gateways are provisioned using their private or public address"
  default = "private"
}
variable "managementServer" {
  type = string
  description = "The name that represents the Security Management Server in the CME configuration"
}
variable "configurationTemplate" {
  type = string
  description = "Name of the provisioning template in the CME configuration"
}

// --- EC2 Instances Configuration ---
variable "instances_name" {
  type = string
  description = "Autoscaling group instances name"
  default = "CP-ASG-gateway-tf"
}
variable "instance_type" {
  type = string
  description = ""
  default = "c5.xlarge"
}
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instances"
}

// --- Auto Scaling Configuration ---
variable "minimum_group_size" {
  type = number
  description = "The minimum number of instances in the Auto Scaling group"
  default = 2
}
variable "maximum_group_size" {
  type = number
  description = "The maximum number of instances in the Auto Scaling group"
  default = 10
}
variable "target_groups" {
  type = list(string)
  description = "(Optional) List of Target Group ARNs to associate with the Auto Scaling group"
  default = []
}

// --- Check Point Settings ---
variable "version_license" {
  type = string
  description =  "Version and license of the Check Point Security Gateways"
  default = "R80.30-PAYG-NGTP-GW"
}
variable "admin_shell" {
  type = string
  description = "Set the admin shell to enable advanced command line configuration"
  default = "/etc/cli.sh"
}
variable "password_hash" {
  type = string
  description = "(Optional) Admin user's password hash (use command \"openssl passwd -1 PASSWORD\" to get the PASSWORD's hash)"
  default = ""
}
variable "SICKey" {
  type = string
  description = "The Secure Internal Communication key for trusted connection between Check Point components (at least 8 alphanumeric characters)"
}
variable "enable_instance_connect" {
  type = bool
  description = "Enable AWS Instance Connect - Ec2 Instance Connect is not supported with versions prior to R80.40"
  default = false
}
variable "allow_upload_download" {
  type = bool
  description = "Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point"
  default = true
}
variable "enable_cloudwatch" {
  type = bool
  description = "Report Check Point specific CloudWatch metrics"
  default = false
}
variable "bootstrap_script" {
  type = string
  description = "(Optional) Semicolon (;) separated commands to run on the initial boot"
  default = ""
}

// --- Outbound Proxy Configuration (optional) ---
variable "proxy_elb_type" {
  type = string
  description = "Type of ELB to create as an HTTP/HTTPS outbound proxy"
  default = "none"
}
variable "proxy_elb_port" {
  type = number
  description = "The TCP port on which the proxy will be listening"
  default = 8080
}
variable "proxy_elb_clients" {
  type = string
  description = "The CIDR range of the clients of the proxy"
  default = "0.0.0.0/0"
}
