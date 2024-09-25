//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- VPC Network Configuration ---
vpc_id = "vpc-12345678"
public_subnet_id = "subnet-123456"
private_subnet_id = "subnet-345678"
private_route_table = "rtb-12345678"

// --- EC2 Instance Configuration ---
standalone_name = "Check-Point-Standalone-tf"
standalone_instance_type = "c5.xlarge"
key_name = "publickey"
allocate_and_associate_eip = true
volume_size = 100
volume_encryption = "alias/aws/ebs"
enable_instance_connect = false
disable_instance_termination = false
metadata_imdsv2_required = true
instance_tags = {
  key1 = "value1"
  key2 = "value2"
}

// --- Check Point Settings ---
standalone_version = "R81.20-BYOL"
admin_shell = "/etc/cli.sh"
standalone_password_hash = ""
standalone_maintenance_mode_password_hash = ""

// --- Advanced Settings ---
resources_tag_name = "tag-name"
standalone_hostname = "standalone-tf"
allow_upload_download = true
enable_cloudwatch = false
standalone_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/bootstrap.txt"
primary_ntp = ""
secondary_ntp = ""
admin_cidr = "0.0.0.0/0"
gateway_addresses = "0.0.0.0/0"