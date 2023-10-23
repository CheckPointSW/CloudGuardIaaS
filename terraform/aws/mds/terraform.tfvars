//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- VPC Network Configuration ---
vpc_id = "vpc-12345678"
subnet_id = "subnet-abc123"

// --- EC2 Instances Configuration ---
mds_name = "CP-MDS-tf"
mds_instance_type = "m5.12xlarge"
key_name = "publickey"
volume_size = 100
volume_encryption = "alias/aws/ebs"
enable_instance_connect = false
disable_instance_termination = false
instance_tags = {
  key1 = "value1"
  key2 = "value2"
}

// --- IAM Permissions ---
iam_permissions = "Create with read permissions"
predefined_role = ""
sts_roles = []

// --- Check Point Settings ---
mds_version = "R81.20-BYOL"
mds_admin_shell = "/etc/cli.sh"
mds_password_hash = ""

// --- Multi-Domain Server Settings ---
mds_hostname = "mds-tf"
mds_SICKey = ""
allow_upload_download = "true"
mds_installation_type = "Primary Multi-Domain Server"
admin_cidr = "0.0.0.0/0"
gateway_addresses = "0.0.0.0/0"
primary_ntp = ""
secondary_ntp = ""
mds_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/bootstrap.txt"
