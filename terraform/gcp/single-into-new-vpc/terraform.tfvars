# --- Google Provider ---
service_account_path                        = "PLEASE ENTER SERVICE_ACCOUNT_PATH"                                       # "service-accounts/service-account-file-name.json"
project                                     = "PLEASE ENTER PROJECT ID"                                                 # "project-id"

# --- Check Point Deployment---
image_name                                  = "PLEASE ENTER IMAGE_NAME"                                                 # "check-point-r8120-gw-byol-single-631-991001335-v20230622"
installationType                            = "PLEASE ENTER INSTALLATION TYPE"                                          # "Gateway only"
license                                     = "PLEASE ENTER LICENSE"                                                    # "BYOL"
prefix                                      = "PLEASE ENTER PREFIX"                                                     # "chkp-single-tf-"
management_nic                              = "PLEASE ENTER MANAGEMENT_NIC"                                             # "Ephemeral Public IP (eth0)"
admin_shell                                 = "PLEASE ENTER ADMIN_SHELL"                                                # "/etc/cli.sh"
admin_SSH_key                               = "PLEASE ENTER ADMIN_SSH_KEY"                                              # "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
generatePassword                            = "PLEASE ENTER GENERATE PASSWORD"                                          # false
allowUploadDownload                         = "PLEASE ENTER ALLOW UPLOAD DOWNLOAD"                                      # false
sicKey                                      = "PLEASE ENTER SIC KEY"                                                    # ""
managementGUIClientNetwork                  = "PLEASE ENTER MANAGEMENT GUI CLIENT NETWORK"                              # "0.0.0.0/0"

# --- Quick connect to Smart-1 Cloud ---
smart_1_cloud_token                         = "PASTE TOKEN FROM SMART-1 CLOUD PORTAL"                                   # ""

# --- Networking---
region                                      = "PLEASE ENTER REGION"                                                     # "us-central1"
zone                                        = "PLEASE ENTER ZONE"                                                       # "us-central1-a"
subnetwork_cidr                             = "PLEASE ENTER SUBNETWORK CIDR"                                            # "10.0.1.0/24"
network_enableTcp                           = "PLEASE ENTER NETWORK ENABLE TCP"                                         # false
network_tcpSourceRanges                     = "PLEASE ENTER NETWORK TCP SOURCE RANGES"                                  # []
network_enableGwNetwork                     = "PLEASE ENTER NETWORK ENABLE GW NETWORK"                                  # false
network_gwNetworkSourceRanges               = "PLEASE ENTER NETWORK GW NETWORK SOURCE RANGES"                           # []
network_enableIcmp                          = "PLEASE ENTER NETWORK ENABLE ICMP"                                        # false
network_icmpSourceRanges                    = "PLEASE ENTER NETWORK ICMP SOURCE RANGES"                                 # []
network_enableUdp                           = "PLEASE ENTER NETWORK ENABLE UDP"                                         #  false
network_udpSourceRanges                     = "PLEASE ENTER NETWORK UDP SOURCE RANGES"                                  # []
network_enableSctp                          = "PLEASE ENTER NETWORK ENABLE SCTP"                                        # false
network_sctpSourceRanges                    = "PLEASE ENTER NETWORK SCTP SOURCE RANGES"                                 # []
network_enableEsp                           = "PLEASE ENTER NETWORK ENABLE ESP"                                         # false
network_espSourceRanges                     = "PLEASE ENTER NETWORK ESP SOURCE RANGES"                                  # []
numAdditionalNICs                           = "PLEASE ENTER NUM ADDITIONAL NICS"                                        # 0
externalIP                                  = "PLEASE ENTER EXTERNAL IP"                                                # "static"
internal_subnetwork_cidr                    = "PLEASE ENTER INTERNAL SUBNETWORK CIDR"                                   # "10.0.2.0/24"

# --- Instances configuration---
machine_type                                = "PLEASE ENTER MACHINE_TYPE"                                               # "n1-standard-4"
diskType                                    = "PLEASE ENTER DISK TYPE"                                                  # "SSD Persistent Disk"
bootDiskSizeGb                              = "PLEASE ENTER BOOT DISK SIZE GB"                                          # 100
enableMonitoring                            = "PLEASE ENTER ENABLE MONITORING"                                          # false