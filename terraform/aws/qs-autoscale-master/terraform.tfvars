//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- Environment ---
prefix = "TF"
asg_name = "asg-qs"

// --- Network Configuration ---
vpc_cidr = "10.0.0.0/16"
public_subnets_map = {
  "us-east-1a" = 1
  "us-east-1b" = 2
}
private_subnets_map = {
  "us-east-1a" = 3
  "us-east-1b" = 4
}
subnets_bit_length = 8

// --- General Settings ---
key_name = "publickey"
enable_volume_encryption = true
enable_instance_connect = false
disable_instance_termination = false
allow_upload_download = true
provision_tag = "quickstart"
load_balancers_type = "Application Load Balancer"
load_balancer_protocol = "HTTP"
certificate = ""
service_port = "80"

// --- Check Point CloudGuard Network Security Gateways Auto Scaling Group Configuration ---
gateway_instance_type = "c5.xlarge"
gateways_min_group_size = 2
gateways_max_group_size = 8
gateway_version = "R81.10-BYOL"
gateway_password_hash = ""
gateway_SICKey = "12345678"
enable_cloudwatch = true

// --- Check Point CloudGuard Network Security Management Server Configuration ---
management_deploy = true
management_instance_type = "m5.xlarge"
management_version = "R81.10-BYOL"
management_password_hash = ""
gateways_policy = "Standard"
gateways_blades = true
admin_cidr = "0.0.0.0/0"
gateways_addresses = "0.0.0.0/0"

// --- Web Servers Auto Scaling Group Configuration ---
servers_deploy = true
servers_instance_type = "t3.micro"
server_ami = "ami-12345abc"