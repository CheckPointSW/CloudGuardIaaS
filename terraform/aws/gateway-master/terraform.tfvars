//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- VPC Network Configuration ---
vpc_cidr = "10.0.0.0/16"
public_subnets_map = {
  "us-east-1a" = 1
}
private_subnets_map = {
  "us-east-1a" = 2
}
subnets_bit_length = 8

// --- EC2 Instance Configuration ---
gateway_name = "Check-Point-Gateway-tf"
gateway_instance_type = "c5.xlarge"
key_name = "privatekey"
allocate_and_associate_eip = true
volume_size = 100
volume_encryption = ""
enable_instance_connect = false
instance_tags = {
  key1 = "value1"
  key2 = "value2"
}

// --- Check Point Settings ---
gateway_version = "R80.40-PAYG-NGTP"
admin_shell = "/bin/bash"
gateway_SICKey = "12345678"
gateway_password_hash = "12345678"

// --- Advanced Settings ---
resources_tag_name = "tag-name"
gateway_hostname = "gw-hostname"
allow_upload_download = true
gateway_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/testfile.txt"
primary_ntp = ""
secondary_ntp = ""

// --- (Optional) Automatic Provisioning with Security Management Server Settings ---
control_gateway_over_public_or_private_address =  "private"
management_server = ""
configuration_template = ""