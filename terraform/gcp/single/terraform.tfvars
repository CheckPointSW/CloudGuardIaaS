# --- Google Provider ---
service_account_path                        = "PLEASE ENTER SERVICE_ACCOUNT_PATH"                                       # "service-accounts/service-account-file-name.json"
project                                     = "PLEASE ENTER PROJECT ID"                                                 # "project-id"  

# --- Check Point Deployment---
image_name                                  = "PLEASE ENTER IMAGE_NAME"                                                 # "check-point-r8120-gw-byol-single-631-991001669-v20240923"
os_version                                  = "PLEASE ENTER GAIA OS VERSION"                                            # "R8120"
installation_type                           = "PLEASE ENTER INSTALLATION TYPE"                                          # "Gateway only"
license                                     = "PLEASE ENTER LICENSE"                                                    # "BYOL"
prefix                                      = "PLEASE ENTER PREFIX"                                                     # "chkp-single-tf-"
management_nic                              = "PLEASE ENTER MANAGEMENT_NIC"                                             # "Ephemeral Public IP (eth0)"
admin_shell                                 = "PLEASE ENTER ADMIN_SHELL"                                                # "/etc/cli.sh"
admin_SSH_key                               = "PLEASE ENTER ADMIN_SSH_KEY"                                              # "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
maintenance_mode_password_hash              = "PLEASE ENTER MAINTENANCE MODE PASSWORD HASH"                             # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
generate_password                           = "PLEASE ENTER GENERATE PASSWORD"                                          # false
allow_upload_download                       = "PLEASE ENTER ALLOW UPLOAD DOWNLOAD"                                      # true
sic_key                                     = "PLEASE ENTER SIC KEY"                                                    # ""
management_gui_client_network               = "PLEASE ENTER MANAGEMENT GUI CLIENT NETWORK"                              # "0.0.0.0/0"


# --- Quick connect to Smart-1 Cloud ---
smart_1_cloud_token                         = "PASTE TOKEN FROM SMART-1 CLOUD PORTAL"                                   # ""    

# --- Networking---
region                                      = "PLEASE ENTER REGION"                                                     # "us-central1"
zone                                        = "PLEASE ENTER ZONE"                                                       # "us-central1-a"
network_name                                = "PLEASE ENTER NETWORK NAME"                                               # ""
subnetwork_name                             = "PLEASE ENTER SUBNETWORK NAME"                                            # ""
network_cidr                                = "PLEASE ENTER NETWORK CIDR"                                               # "10.0.1.0/24"
TCP_traffic                                 = "PLEASE ENTER NETWORK TCP SOURCE RANGES"                                  # []  
ICMP_traffic                                = "PLEASE ENTER NETWORK ICMP SOURCE RANGES"                                 # []   
UDP_traffic                                 = "PLEASE ENTER NETWORK UDP SOURCE RANGES"                                  # []  
SCTP_traffic                                = "PLEASE ENTER NETWORK SCTP SOURCE RANGES"                                 # []   
ESP_traffic                                 = "PLEASE ENTER NETWORK ESP SOURCE RANGES"                                  # []                                 
num_additional_networks                     = "PLEASE ENTER NUM ADDITIONAL INTERNAL NETWORKS"                           # 1
external_ip                                 = "PLEASE ENTER EXTERNAL IP"                                                # "static"
internal_network1_name                      = "PLEASE ENTER INTERNAL NETWORK1 NAME"                                     # ""
internal_network1_subnetwork_name           = "PLEASE ENTER INTERNAL SUBNETWORK1 NAME"                                  # ""
internal_network1_cidr                      = "PLEASE ENTER INTERNAL NETWORK1 CIDR"                                     # "10.0.2.0/24"


# --- Instances configuration---
machine_type                                = "PLEASE ENTER MACHINE_TYPE"                                               # "n1-standard-4"
disk_type                                   = "PLEASE ENTER DISK TYPE"                                                  # "SSD Persistent Disk"
disk_size                                   = "PLEASE ENTER BOOT DISK SIZE GB"                                          # 100
enable_monitoring                           = "PLEASE ENTER ENABLE MONITORING"                                          # false
