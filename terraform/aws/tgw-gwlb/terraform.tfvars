//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- VPC Network Configuration ---
vpc_id = "vpc-12345678"
internet_gateway_id ="igw-12345"
availability_zones = ["us-east-1a", "us-east-1b"]
number_of_AZs = 2
gateways_subnets= ["subnet-123456", "subnet-234567"]

transit_gateway_attachment_subnet_1_id="subnet-3456"
transit_gateway_attachment_subnet_2_id="subnet-4567"
transit_gateway_attachment_subnet_3_id="subnet-5678"
transit_gateway_attachment_subnet_4_id="subnet-6789"

nat_gw_subnet_1_cidr ="10.0.13.0/24"
nat_gw_subnet_2_cidr = "10.0.23.0/24"
nat_gw_subnet_3_cidr = "10.0.33.0/24"
nat_gw_subnet_4_cidr = "10.0.43.0/24"

gwlbe_subnet_1_cidr = "10.0.14.0/24"
gwlbe_subnet_2_cidr = "10.0.24.0/24"
gwlbe_subnet_3_cidr = "10.0.34.0/24"
gwlbe_subnet_4_cidr = "10.0.44.0/24"

// --- General Settings ---
key_name = "publickey"
enable_volume_encryption = true
volume_size = 100
enable_instance_connect = false
disable_instance_termination = false
metadata_imdsv2_required = true
allow_upload_download = true
management_server = "CP-Management-gwlb-tf"
configuration_template = "gwlb-configuration"
admin_shell = "/etc/cli.sh"

// --- Gateway Load Balancer Configuration ---
gateway_load_balancer_name = "gwlb1"
target_group_name = "tg1"
enable_cross_zone_load_balancing = "true"

// --- Check Point CloudGuard IaaS Security Gateways Auto Scaling Group Configuration ---
gateway_name = "Check-Point-GW-tf"
gateway_instance_type = "c6in.xlarge"
minimum_group_size = 2
maximum_group_size = 10
gateway_version = "R81.20-BYOL"
gateway_password_hash = ""
gateway_maintenance_mode_password_hash = "" # For R81.10 and below the gateway_password_hash is used also as maintenance-mode password.
gateway_SICKey = "12345678"
gateways_provision_address_type = "private"
allocate_public_IP = false
enable_cloudwatch = false
gateway_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/bootstrap.txt"

// --- Check Point CloudGuard IaaS Security Management Server Configuration ---
management_deploy = true
management_instance_type = "m5.xlarge"
management_version = "R81.20-BYOL"
management_password_hash = ""
management_maintenance_mode_password_hash = "" # For R81.10 and below the management_password_hash is used also as maintenance-mode password.
gateways_policy = "Standard"
gateway_management = "Locally managed"
admin_cidr = "0.0.0.0/0"
gateways_addresses = "0.0.0.0/0"

// --- Other parameters ---
volume_type = "gp3"

