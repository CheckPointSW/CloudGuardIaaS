//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- VPC Network Configuration ---
vpc_id = "vpc-12345678"
public_subnet_id = "subnet-123456"
private_subnet_id = "subnet-345678"
private_route_table = "rtb-12345678"

// --- EC2 Instance Configuration ---
gateway_name = "Check-Point-Gateway-tf"
gateway_instance_type = "c5.xlarge"
key_name = "publickey"
allocate_and_associate_eip = true
volume_size = 100
volume_encryption = "alias/aws/ebs"
enable_instance_connect = false
disable_instance_termination = false
instance_tags = {
  key1 = "value1"
  key2 = "value2"
}

// --- Check Point Settings ---
gateway_version = "R81-BYOL"
admin_shell = "/bin/bash"
gateway_SICKey = "12345678"
gateway_password_hash = ""

// --- Quick connect to Smart-1 Cloud (Recommended) ---
gateway_TokenKey = ""

// --- Advanced Settings ---
resources_tag_name = "tag-name"
gateway_hostname = "gw-hostname"
allow_upload_download = true
enable_cloudwatch = false
gateway_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/testfile.txt"
primary_ntp = ""
secondary_ntp = ""

// --- Automatic Provisioning with Security Management Server Settings (optional) ---
control_gateway_over_public_or_private_address =  "private"
management_server = ""
configuration_template = ""