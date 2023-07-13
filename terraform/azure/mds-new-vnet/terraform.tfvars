#PLEASE refer to the README.md for accepted values for the variables below
client_secret                   = "PLEASE ENTER CLIENT SECRET"                                     # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
client_id                       = "PLEASE ENTER CLIENT ID"                                         # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
tenant_id                       = "PLEASE ENTER TENANT ID"                                         # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
subscription_id                 = "PLEASE ENTER SUBSCRIPTION ID"                                   # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
source_image_vhd_uri            = "PLEASE ENTER SOURCE IMAGE VHD URI OR noCustomUri"               # "noCustomUri"
resource_group_name             = "PLEASE ENTER RESOURCE GROUP NAME"                               # "checkpoint-mds-rg-terraform"
mds_name                        = "PLEASE ENTER MDS NAME"                                          # "checkpoint-mds-terraform"
location                        = "PLEASE ENTER LOCATION"                                          # "eastus"
vnet_name                       = "PLEASE ENTER VIRTUAL NETWORK NAME"                              # "checkpoint-mds-vnet"
address_space                   = "PLEASE ENTER VIRTUAL NETWORK ADDRESS SPACE"                     # "10.0.0.0/16"
subnet_prefix                   = "PLEASE ENTER ADDRESS PREFIX FOR SUBNET"                         # "10.0.0.0/24"
management_GUI_client_network   = "PLEASE ENTER A MANAGEMENT GUI CLIENT NETWORK"                   # "0.0.0.0/0"
mds_enable_api                  = "PLEASE ENTER FOR WHOM TO ENABLE API ACCESS OR disable"          # "disable"
admin_password                  = "PLEASE ENTER ADMIN PASSWORD"                                    # "xxxxxxxxxxxx"
vm_size                         = "PLEASE ENTER VM SIZE"                                           # "Standard_D3_v2"
disk_size                       = "PLEASE ENTER DISK SIZE"                                         # "110"
vm_os_sku                       = "PLEASE ENTER VM SKU"                                            # "mgmt-byol"
vm_os_offer                     = "PLEASE ENTER VM OFFER"                                          # "check-point-cg-r8110"
os_version                      = "PLEASE ENTER GAIA OS VERSION"                                   # "R81.10"
bootstrap_script                = "PLEASE ENTER CUSTOM SCRIPT OR LEAVE EMPTY DOUBLE QUOTES"        # "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
allow_upload_download           = "PLEASE ENTER true or false"                                     # true
authentication_type             = "PLEASE ENTER AUTHENTICATION TYPE"                               # "Password"
admin_shell                     = "PLEASE ENTER ADMIN SHELL"                                       # "/etc/cli.sh"
sic_key                         = "PLEASE ENTER SIC KEY"                                           # "xxxxxxxxxxxx"
installation_type               = "PLEASE ENTER INSTALLATION TYPE"								   # "mds-primary"
primary                         = "PLEASE ENTER true or false"								       # "true"
secondary                       = "PLEASE ENTER true or false"								       # "false"
logserver                       = "PLEASE ENTER true or false"								       # "false"
serial_console_password_hash    = "PLEASE ENTER SERIAL CONSOLE PASSWORD HASH"                      # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
maintenance_mode_password_hash  = "PLEASE ENTER MAINTENANCE MODE PASSWORD HASH"                    # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"