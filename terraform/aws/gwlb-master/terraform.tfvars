//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- Network Configuration ---
vpc_cidr = "10.0.0.0/16"
public_subnets_map = {
  "us-east-1a" = 1
  "us-east-1b" = 2
}
subnets_bit_length = 8

// --- General Settings ---
key_name = "publickey"
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
connection_acceptance_required = "false"
enable_cross_zone_load_balancing = "true"

// --- Check Point CloudGuard IaaS Security Gateways Auto Scaling Group Configuration ---
gateway_name = "Check-Point-GW-tf"
gateway_instance_type = "c5.xlarge"
minimum_group_size = 2
maximum_group_size = 10
gateway_version = "R80.40-BYOL"
gateway_password_hash = ""
gateway_SICKey = "12345678"
gateways_provision_address_type = "private"
allocate_public_IP = false
enable_cloudwatch = false

// --- Check Point CloudGuard IaaS Security Management Server Configuration ---
management_deploy = true
management_instance_type = "m5.xlarge"
management_version = "R81.10-BYOL"
management_password_hash = ""
gateways_policy = "Standard"
gateway_management = "Locally managed"
admin_cidr = "0.0.0.0/0"
gateways_addresses = "0.0.0.0/0"

// --- Other parameters ---
volume_type = "gp3"

