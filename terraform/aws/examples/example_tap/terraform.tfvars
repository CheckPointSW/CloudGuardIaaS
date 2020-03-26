region = "ap-east-1"

// --- VPC Network Configuration ---
vpc_id = "vpc-048eeb284b845ef72"
external_subnet_id = "subnet-0dbc66fd0d99448ff"
internal_subnet_id = "subnet-03a39ad28a7122323"
resources_tag_name = "mbd-tap"

// --- TAP Configuration ---
registration_key = "10:10:10:10:10:10"
vxlan_id = 10
blacklist_tags = {
  env = "staging"
  mood = "hungry"
}
schedule_scan_interval = 10

// --- EC2 Instance Configuration ---
instance_name = "mbd-tap-instance"
instance_type = "c5.large"
key_name = "marlenbd"
password_hash = "$1$hhdwDdRG$5NOrisaYtANfeCl1zK3EX1"

// --- Check Point Settings ---
version_license = "R80.40-PAYG-NGTP-GW"
