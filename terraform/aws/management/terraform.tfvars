//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- VPC Network Configuration ---
vpc_id = "vpc-12345678"
subnet_id = "subnet-abc123"

// --- EC2 Instances Configuration ---
management_name = "CP-Management-tf"
management_instance_type = "m5.xlarge"
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

// --- IAM Permissions ---
iam_permissions = "Create with read permissions"
predefined_role = ""
sts_roles = []

// --- Check Point Settings ---
management_version = "R81.10-BYOL"
admin_shell = "/bin/bash"
management_password_hash = "12345678"

// --- Security Management Server Settings ---
management_hostname = "mgmt-tf"
is_primary_management = "true"
SICKey = ""
allow_upload_download = "true"
gateway_management = "Locally managed"
admin_cidr = "0.0.0.0/0"
gateway_addresses = "0.0.0.0/0"
primary_ntp = ""
secondary_ntp = ""
management_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/testfile.txt"
