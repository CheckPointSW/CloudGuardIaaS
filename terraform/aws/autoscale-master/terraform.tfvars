//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- Environment ---
prefix = "env1"
asg_name = "autoscaling_group"

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

// --- Automatic Provisioning with Security Management Server Settings ---
gateways_provision_address_type = "private"
management_server = "mgmt_env1"
configuration_template = "tmpl_env1"

// --- EC2 Instances Configuration ---
gateway_name = "asg_gateway"
gateway_instance_type = "c6in.xlarge"
key_name = "publickey"
instances_tags = {
  key1 = "value1"
  key2 = "value2"
}
metadata_imdsv2_required = true

// --- Auto Scaling Configuration ---
minimum_group_size = 2
maximum_group_size = 10
target_groups = ["arn:aws:tg1/abc123", "arn:aws:tg2/def456"]

// --- Check Point Settings ---
gateway_version = "R81.20-BYOL"
admin_shell = "/etc/cli.sh"
gateway_password_hash = ""
gateway_maintenance_mode_password_hash = "" # For R81.10 and below the gateway_password_hash is used also as maintenance-mode password.
gateway_SICKey = "12345678"
enable_instance_connect = false
allow_upload_download = true
enable_cloudwatch = false
gateway_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/bootstrap.txt"

// --- Outbound Proxy Configuration (optional) ---
proxy_elb_type = "internet-facing"
proxy_elb_clients = "0.0.0.0/0"
proxy_elb_port = 8080
