region = "us-east-1"

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
key_name = "privatekey"
password_hash = "12345678"

// --- Check Point Settings ---
version_license = "R80.40-PAYG-NGTP-GW"
