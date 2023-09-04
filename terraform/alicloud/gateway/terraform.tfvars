//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- VPC Network Configuration ---
vpc_id = "vpc-"
public_vswitch_id = "vsw-"
private_vswitch_id = "vsw-"
private_route_table = "vtb-"

// --- ECS Instance Configuration ---
gateway_name = "Check-Point-Gateway-tf"
gateway_instance_type = "ecs.g5ne.xlarge"
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
gateway_TokenKey = ""

// --- Advanced Settings ---
resources_tag_name = "tag-name"
gateway_hostname = "gw-hostname"
allow_upload_download = true
gateway_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/testfile.txt"
primary_ntp = "ntp1.cloud.aliyuncs.com"
secondary_ntp = "ntp2.cloud.aliyuncs.com"