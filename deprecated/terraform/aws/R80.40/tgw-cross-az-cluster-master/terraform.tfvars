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

// --- EC2 Instance Configuration ---
gateway_name = "Check-Point-Cluster-tf"
gateway_instance_type = "c5.xlarge"
key_name = "publickey"
volume_size = 100
volume_encryption = "alias/aws/ebs"
enable_instance_connect = false
disable_instance_termination = false
metadata_imdsv2_required = true

predefined_role = ""

// --- Check Point Settings ---
gateway_version = "R81.20-BYOL"
admin_shell = "/etc/cli.sh"
gateway_SICKey = "12345678"
gateway_password_hash = ""
gateway_maintenance_mode_password_hash = "" # For R81.10 and below the gateway_password_hash is used also as maintenance-mode password.
// --- Quick connect to Smart-1 Cloud (Recommended) ---
memberAToken = ""
memberBToken = ""

// --- Advanced Settings ---
resources_tag_name = "tag-name"
gateway_hostname = "gw-hostname"
allow_upload_download = true
enable_cloudwatch = false
gateway_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/bootstrap.txt"
primary_ntp = ""
secondary_ntp = ""