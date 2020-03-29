region = "us-east-1"

// --- Environment ---
prefix = "env1"
asg_name = "autoscaling_group"

// --- VPC Network Configuration ---
vpc_id = "vpc-12345678"
subnet_ids = ["subnet-abc123", "subnet-def456"]

// --- Automatic Provisioning with Security Management Server Settings ---
gateways_provision_address_type = "private"
managementServer = "mgmt_env1"
configurationTemplate = "tmpl_env1"

// --- EC2 Instances Configuration ---
instances_name = "asg_gateway"
instance_type = "c5.xlarge"
key_name = "privatekey"

// --- Auto Scaling Configuration ---
minimum_group_size = 2
maximum_group_size = 10
target_groups = ["arn:aws:tg1/abc123", "arn:aws:tg2/def456"]

// --- Check Point Settings ---
version_license = "R80.30-PAYG-NGTP-GW"
admin_shell = "/bin/bash"
password_hash = "12345678"
SICKey = "12345678"
enable_instance_connect = false
allow_upload_download = true
enable_cloudwatch = false
bootstrap_script = "echo 12345678"

// --- Outbound Proxy Configuration (optional) ---
proxy_elb_type = "internet-facing"
proxy_elb_clients = "0.0.0.0/0"
proxy_elb_port = 8080
