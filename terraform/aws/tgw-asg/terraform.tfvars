//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- Network Configuration ---
vpc_id = "vpc-12345678"
gateways_subnets = ["subnet-123b5678", "subnet-123a4567"]

// --- General Settings ---
key_name = "publickey"
enable_volume_encryption = true
enable_instance_connect = false
disable_instance_termination = false
allow_upload_download = true

// --- Check Point CloudGuard Network Security Gateways Auto Scaling Group Configuration ---
gateway_name = "Check-Point-gateway"
gateway_instance_type = "c5.xlarge"
gateways_min_group_size = 2
gateways_max_group_size = 8
gateway_version = "R81.10-BYOL"
gateway_password_hash = ""
gateway_SICKey = "12345678"
enable_cloudwatch = true
asn = "65000"

// --- Check Point CloudGuard Network Security Management Server Configuration ---
management_deploy = true
management_instance_type = "m5.xlarge"
management_version = "R81.10-BYOL"
management_password_hash = "12345678"
management_permissions = "Create with read-write permissions"
management_predefined_role = ""
gateways_blades = true
admin_cidr = "0.0.0.0/0"
gateways_addresses = "0.0.0.0/0"
gateway_management = "Locally managed"

// --- Automatic Provisioning with Security Management Server Settings ---
control_gateway_over_public_or_private_address = "private"
management_server = "management-server"
configuration_template = "template-name"