region = "ap-east-1"

// --- Environment ---
prefix = "env1"
asg_name = "autoscaling_group"

// --- VPC Network Configuration ---
vpc_id = "vpc-048eeb284b845ef72"
subnet_ids = ["subnet-0dbc66fd0d99448ff", "subnet-06b0968432f7593b2"]

// --- Automatic Provisioning with Security Management Server Settings ---
gateways_provision_address_type = "private"
managementServer = "mgmt_env1"
configurationTemplate = "tmpl_env1"

// --- EC2 Instances Configuration ---
instances_name = "asg_gateway"
instance_type = "c5.xlarge"
key_name = "marlenbd"

// --- Auto Scaling Configuration ---
minimum_group_size = 1
maximum_group_size = 2
target_groups = ["arn:aws:elasticloadbalancing:ap-east-1:406406155863:targetgroup/mbd-ext-tg1/45149fd2f047f69b", "arn:aws:elasticloadbalancing:ap-east-1:406406155863:targetgroup/mbd-ext-tg2/8c4ef3586417057c"]

// --- Check Point Settings ---
version_license = "R80.40-PAYG-NGTP-GW"
admin_shell = "/bin/bash"
password_hash = "$1$hhdwDdRG$5NOrisaYtANfeCl1zK3EX1"
SICKey = "12345678"
enable_instance_connect = true
allow_upload_download = true
enable_cloudwatch = false
bootstrap_script = "touch /home/admin/marlen_bootstrap.txt; echo 'hi' > /home/admin/marlen_bootstrap.txt"

// --- Outbound Proxy Configuration (optional) ---
proxy_elb_type = "internet-facing"
proxy_elb_clients = "0.0.0.0/0"
proxy_elb_port = 8080
