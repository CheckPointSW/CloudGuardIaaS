//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- VPC Network Configuration ---
vpc_cidr = "10.29.0.0/16"
public_subnets_map = {
  "us-east-1a" = 1
  "us-east-1b" = 2
}
private_subnets_map = {
  "us-east-1a" = 3
  "us-east-1b" = 4
}
tgw_subnets_map = {
  "us-east-1a" = 5
  "us-east-1b" = 6
}
subnets_bit_length = 8

availability_zones = ["us-east-1a", "us-east-1b"]

// --- EC2 Instance Configuration ---
gateway_name = "Check-Point-Cluster-tf"
gateway_instance_type = "c5.xlarge"
key_name = "key"
volume_size = 100
volume_encryption = "alias/aws/ebs"
enable_instance_connect = false
disable_instance_termination = false

predefined_role = ""

// --- Check Point Settings ---
gateway_version = "R81.20-BYOL"
admin_shell = "/bin/bash"
gateway_SICKey = ""
gateway_password_hash = ""

// --- Advanced Settings ---
resources_tag_name = "tag-name"
gateway_hostname = "gw-hostname"
allow_upload_download = true
gateway_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/testfile.txt"
primary_ntp = ""
secondary_ntp = ""