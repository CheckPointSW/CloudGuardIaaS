# --- Google Provider ---
service_account_path              = "PLEASE ENTER SERVICE ACCOUNT PATH"           # "service-accounts/service-account-file-name.json"
project                           = "PLEASE ENTER PROJECT NAME"                   # "project-name"

# --- Check Point---
prefix                            = "PLEASE ENTER PREFIX"                         # "chkp-tf-mig"
license                           = "PLEASE ENTER LICENSE"                        # "BYOL"
image_name                        = "PLEASE ENTER IMAGE NAME"                     # "check-point-r8040-gw-byol-mig-123-456-v12345678"
management_nic                    = "PLEASE ENTER MANAGEMENT INTERFACE"           # "Ephemeral Public IP (eth0)"
management_name                   = "PLEASE ENTER MANAGEMENT NAME"                # "tf-checkpoint-management"
configuration_template_name       = "PLEASE ENTER CONFIGURATION TEMPLATE NAME"    # "tf-asg-autoprov-tmplt"
admin_SSH_key                     = "PLEASE ENTER ADMIN SSH KEY"                  # "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
network_defined_by_routes         = "PLEASE ENTER true OR false"                  # true
admin_shell                       = "PLEASE ENTER ADMIN SHELL"                    # "/etc/cli.sh"
allow_upload_download             = "PLEASE ENTER true OR false"                  # true

# --- Networking ---
region                            = "PLEASE ENTER REGION"                         # "us-central1"
external_subnetwork_ip_cidr_range = "PLEASE ENTER EXTERNAL SUBNETWORK CIDR"       # "10.0.1.0/24"
internal_subnetwork_ip_cidr_range = "PLEASE ENTER INTERNAL SUBNETWORK CIDR"       # "10.0.2.0/24"
ICMP_traffic                      = "PLEASE ENTER ICMP SOURCE IP RANGES"          # ["123.123.0.0/24", "234.234.0.0/24"]
TCP_traffic                       = "PLEASE ENTER TCP SOURCE IP RANGES"           # ["0.0.0.0/0"]
UDP_traffic                       = "PLEASE ENTER UDP SOURCE IP RANGES"           # []
SCTP_traffic                      = "PLEASE ENTER SCTP SOURCE IP RANGES"          # []
ESP_traffic                       = "PLEASE ENTER ESP SOURCE IP RANGES"           # []

# --- Instance Configuration ---
machine_type                      = "PLEASE ENTER MACHINE TYPE"                   # "n1-standard-4"
cpu_usage                         = "PLEASE ENTER CPU USAGE"                      # 60
instances_min_grop_size           = "PLEASE ENTER INSTANCES MIN GROP SIZE"        # 2
instances_max_grop_size           = "PLEASE ENTER INSTANCES MAX GROP SIZE"        # 10
disk_type                         = "PLEASE ENTER DISK TYPE"                      # "SSD Persistent Disk"
disk_size                         = "PLEASE ENTER DISK SIZE"                      # 100
enable_monitoring                 = "PLEASE ENTER true OR false"                  # false