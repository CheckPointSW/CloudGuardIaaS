//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- VPC Network Configuration ---
vpc_name = "cp-vpc"
vpc_cidr = "10.0.0.0/16"
cluster_vswitchs_map = {
  "us-east-1a" = 1
}
management_vswitchs_map = {
  "us-east-1a" = 2
}
private_vswitchs_map = {
  "us-east-1a" = 3
}
vswitchs_bit_length = 8

// --- ECS Instance Configuration ---
gateway_name = "Check-Point-Cluster-tf"
gateway_instance_type = "ecs.g5ne.large"
key_name = "publickey"
allocate_and_associate_eip = true
volume_size = 100
disk_category = "cloud_efficiency"
ram_role_name = ""
instance_tags = {
  key1 = "value1"
  key2 = "value2"
}

// --- Check Point Settings ---
gateway_version = "R81.20-BYOL"
admin_shell = "/etc/cli.sh"
gateway_SICKey = "12345678"
gateway_password_hash = ""

// --- Quick connect to Smart-1 Cloud (Recommended) ---
memberAToken = ""
memberBToken = ""

// --- Advanced Settings ---
management_ip_address = "1.2.3.4"
resources_tag_name = "tag-name"
gateway_hostname = "gw-hostname"
allow_upload_download = true
gateway_bootstrap_script = ""
primary_ntp = "ntp1.cloud.aliyuncs.com"
secondary_ntp = "ntp2.cloud.aliyuncs.com"
