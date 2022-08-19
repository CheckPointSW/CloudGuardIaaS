# --- Google Provider ---
project                               = "PLEASE ENTER PROJECT NAME"                   # "project-name"

# --- Check Point Deployment ---
prefix                                = "PLEASE ENTER PREFIX"                         # "chkp-tf-ha"
license                               = "PLEASE ENTER LICENSE"                        # "BYOL"
image_name                            = "PLEASE ENTER IMAGE NAME"                     # "check-point-r8040-gw-byol-cluster-123-456-v12345678"

# --- Instances Configuration ---
region                                = "PLEASE ENTER REGION"                         # "us-central1"
zoneA                                 = "PLEASE ENTER ZONE A"                         # "us-central1-a"
zoneB                                 = "PLEASE ENTER ZONE B"                         # "us-central1-a"
machine_type                          = "PLEASE ENTER MACHINE TYPE"                   # "n1-standard-4"
disk_type                             = "PLEASE ENTER DISK TYPE"                      # "SSD Persistent Disk"
disk_size                             = "PLEASE ENTER DISK SIZE"                      # 100
admin_SSH_key                         = "PLEASE ENTER ADMIN SSH KEY"                  # "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
enable_monitoring                     = "PLEASE ENTER true OR false"                  # false

# --- Check Point ---
management_network                    = "PLEASE ENTER MANAGEMENT IP"                  # "209.87.209.100/32"
sic_key                               = "PLEASE ENTER A SIC KEY"                      # "aaaaaaaa"
generate_password                     = "PLEASE ENTER true or false"                  # false
allow_upload_download                 = "PLEASE ENTER true OR false"                  # true
admin_shell                           = "PLEASE ENTER ADMIN SHELL"                    # "/etc/cli.sh"

# --- Networking ---
cluster_network_cidr                  = "PLEASE ENTER CLUSTER NETWORK CIDR"           # "10.0.1.0/24"
cluster_network_name                  = "PLEASE ENTER CLUSTER NETWORK ID"             # "cluster-network"
cluster_network_subnetwork_name       = "PLEASE ENTER CLUSTER SUBNETWORK ID"          # "cluster-subnetwork"
cluster_ICMP_traffic                  = "PLEASE ENTER ICMP SOURCE IP RANGES"          # ["123.123.0.0/24", "234.234.0.0/24"]
cluster_TCP_traffic                   = "PLEASE ENTER TCP SOURCE IP RANGES"           # ["0.0.0.0/0"]
cluster_UDP_traffic                   = "PLEASE ENTER UDP SOURCE IP RANGES"           # []
cluster_SCTP_traffic                  = "PLEASE ENTER SCTP SOURCE IP RANGES"          # []
cluster_ESP_traffic                   = "PLEASE ENTER ESP SOURCE IP RANGES"           # []
mgmt_network_cidr                     = "PLEASE ENTER MANAGEMENT NETWORK CIDR"        # ""
mgmt_network_name                     = "PLEASE ENTER MANAGEMENT NETWORK ID"          # "mgmt-network"
mgmt_network_subnetwork_name          = "PLEASE ENTER MANAGEMENT SUBNETWORK ID"       # "mgmt-subnetwork"
mgmt_ICMP_traffic                     = "PLEASE ENTER ICMP SOURCE IP RANGES"          # ["123.123.0.0/24", "234.234.0.0/24"]
mgmt_TCP_traffic                      = "PLEASE ENTER TCP SOURCE IP RANGES"           # ["0.0.0.0/0"]
mgmt_UDP_traffic                      = "PLEASE ENTER UDP SOURCE IP RANGES"           # []
mgmt_SCTP_traffic                     = "PLEASE ENTER SCTP SOURCE IP RANGES"          # []
mgmt_ESP_traffic                      = "PLEASE ENTER ESP SOURCE IP RANGES"           # []
num_internal_networks                 = "PLEASE ENTER A NUMBER OF ADDITIONAL NICS"    # 1
internal_network1_cidr                = "PLEASE ENTER 1ST INTERNAL NETWORK CIDR"      # "10.0.3.0/24"
internal_network1_name                = "PLEASE ENTER 1ST INTERNAL NETWORK ID"        # ""
internal_network1_subnetwork_name     = "PLEASE ENTER INTERNAL SUBNETWORK ID"         # ""

#Define internal NICs networks and subnetworks according the defined num_internal_networks value
