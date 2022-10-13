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
standalone_name = "Check-Point-Standalone-tf"
standalone_instance_type = "c5.xlarge"
key_name = "privatekey"
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
standalone_version = "R81-PAYG-NGTP"
admin_shell = "/bin/bash"
standalone_password_hash = "12345678"

// --- Advanced Settings ---
resources_tag_name = "tag-name"
standalone_hostname = "standalone-tf"
allow_upload_download = true
standalone_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/testfile.txt"
primary_ntp = ""
secondary_ntp = ""
admin_cidr = "0.0.0.0/0"
gateway_addresses = "0.0.0.0/0"