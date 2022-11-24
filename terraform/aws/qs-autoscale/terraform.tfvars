//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- Environment ---
prefix = "TF"
asg_name = "asg-qs"

// --- General Settings ---
vpc_id = "vpc-12345678"
key_name = "privatekey"
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
gateways_subnets = ["subnet-123b5678", "subnet-123a4567"]
gateway_instance_type = "c5.xlarge"
gateways_min_group_size = 2
gateways_max_group_size = 8
gateway_version = "R81.10-BYOL"
gateway_password_hash = "12345678"
gateway_SICKey = ""
enable_cloudwatch = true

// --- Check Point CloudGuard Network Security Management Server Configuration ---
management_deploy = true
management_instance_type = "m5.xlarge"
management_version = "R81.10-BYOL"
management_password_hash = "12345678"
gateways_policy = "Standard"
gateways_blades = true
admin_cidr = "0.0.0.0/0"
gateways_addresses = "0.0.0.0/0"

// --- Web Servers Auto Scaling Group Configuration ---
servers_deploy = false
servers_subnets = ["subnet-1234abcd", "subnet-56789def"]
servers_instance_type = "t3.micro"
server_ami = "ami-12345678"