//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- Credentials ---
//region = "us-east-1"
//alicloud_access_key_ID = "12345"
//alicloud_secret_access_key = "12345"

// --- VPC Network Configuration ---
vpc_id = "vpc-"
cluster_vswitch_id = "vsw-"
mgmt_vswitch_id = "vsw-"
private_vswitch_id = "vsw-"
private_route_table = "vtb-"

// --- ECS Instance Configuration ---
gateway_name = "Check-Point-Cluster-tf"
gateway_instance_type = "ecs.g5ne.xlarge"
key_name = "key"
allocate_and_associate_eip = true
volume_size = 100
ram_role_name = "role_name"
instance_tags = {
  key1 = "value1"
  key2 = "value2"
}

// --- Check Point Settings ---
gateway_version = "R81-BYOL"
admin_shell = "/bin/bash"
gateway_SICKey = "12345678"
gateway_password_hash = "12345678"

// --- Advanced Settings ---
management_ip_address = "1.2.3.4"
resources_tag_name = "tag-name"
gateway_hostname = "gw-hostname"
allow_upload_download = true
gateway_bootstrap_script = ""
primary_ntp = ""
secondary_ntp = ""