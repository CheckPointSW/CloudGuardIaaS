//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- VPC Network Configuration ---
vpc_cidr = "10.0.0.0/16"
public_subnets_map = {
  "us-east-1a" = 1
  "us-east-1b" = 2
  "us-east-1c" = 3
  "us-east-1d" = 4
}
tgw_subnets_map = {
  "us-east-1a" = 5
  "us-east-1b" = 6
  "us-east-1c" = 7
  "us-east-1d" = 8
}
subnets_bit_length = 8

availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
number_of_AZs = 4

nat_gw_subnet_1_cidr ="10.0.13.0/24"
nat_gw_subnet_2_cidr = "10.0.23.0/24"
nat_gw_subnet_3_cidr = "10.0.33.0/24"
nat_gw_subnet_4_cidr = "10.0.43.0/24"

gwlbe_subnet_1_cidr = "10.0.14.0/24"
gwlbe_subnet_2_cidr = "10.0.24.0/24"
gwlbe_subnet_3_cidr = "10.0.34.0/24"
gwlbe_subnet_4_cidr = "10.0.44.0/24"

// --- General Settings ---
key_name = "key"
enable_volume_encryption = true
volume_size = 100
enable_instance_connect = false
disable_instance_termination = false
allow_upload_download = true
management_server = "CP-Management-gwlb-tf"
configuration_template = "gwlb-configuration"
admin_shell = "/bin/bash"

// --- Gateway Load Balancer Configuration ---
gateway_load_balancer_name = "gwlb1"
target_group_name = "tg1"
enable_cross_zone_load_balancing = "true"

// --- Check Point CloudGuard IaaS Security Gateways Auto Scaling Group Configuration ---
gateway_name = "Check-Point-GW-tf"
gateway_instance_type = "c5.xlarge"
minimum_group_size = 2
maximum_group_size = 10
gateway_version = "R80.40-BYOL"
gateway_password_hash = "12345678"
gateway_SICKey = "12345678"
gateways_provision_address_type = "private"
allocate_public_IP = false
enable_cloudwatch = false

// --- Check Point CloudGuard IaaS Security Management Server Configuration ---
management_deploy = true
management_instance_type = "m5.xlarge"
management_version = "R81.10-BYOL"
management_password_hash = "12345678"
gateways_policy = "Standard"
gateway_management = "Locally managed"
admin_cidr = "0.0.0.0/0"
gateways_addresses = "0.0.0.0/0"

// --- Other parameters ---
volume_type = "gp3"

