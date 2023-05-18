//PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

// --- VPC Network Configuration ---
vpc_id = "vpc-12345678"
external_subnet_id = "subnet-abc123"
internal_subnet_id = "subnet-def456"
resources_tag_name = "env1"

// --- TAP Configuration ---
registration_key = "10:10:10:10:10:10"
vxlan_id = 10
blacklist_tags = {
  env = "staging"
  state = "stable"
}
schedule_scan_interval = 60

// --- EC2 Instance Configuration ---
instance_name = "tap-gateway"
instance_type = "c5.xlarge"
key_name = "publickey"
