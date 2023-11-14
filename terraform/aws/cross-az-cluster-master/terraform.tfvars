//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- VPC Network Configuration ---
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

// --- EC2 Instance Configuration ---
gateway_name = "Check-Point-Cluster-tf"
gateway_instance_type = "c5.xlarge"
key_name = "publickey"
volume_size = 100
volume_encryption = "alias/aws/ebs"
enable_instance_connect = false
disable_instance_termination = false
instance_tags = {
  key1 = "value1"
  key2 = "value2"
}
predefined_role = ""

// --- Check Point Settings ---
gateway_version = "R81.20-BYOL"
admin_shell = "/etc/cli.sh"
gateway_SICKey = "12345678"
gateway_password_hash = ""

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