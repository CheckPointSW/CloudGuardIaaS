//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- Environment ---
prefix = "env1"
asg_name = "autoscaling_group"

// --- VPC Network Configuration ---
vpc_id = "vpc-12345678"
subnet_ids = ["subnet-abc123", "subnet-def456"]

// --- Automatic Provisioning with Security Management Server Settings ---
gateways_provision_address_type = "private"
allocate_public_IP = false
management_server = "mgmt_env1"
configuration_template = "tmpl_env1"

// --- EC2 Instances Configuration ---
gateway_name = "asg_gateway"
gateway_instance_type = "c5.xlarge"
key_name = "publickey"
instances_tags = {
  key1 = "value1"
  key2 = "value2"
}

// --- Auto Scaling Configuration ---
minimum_group_size = 2
maximum_group_size = 10
target_groups = ["arn:aws:tg1/abc123", "arn:aws:tg2/def456"]

// --- Check Point Settings ---
gateway_version = "R81.20-BYOL"
admin_shell = "/etc/cli.sh"
gateway_password_hash = ""
gateway_SICKey = "12345678"
enable_instance_connect = false
allow_upload_download = true
enable_cloudwatch = false
gateway_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/bootstrap.txt"

