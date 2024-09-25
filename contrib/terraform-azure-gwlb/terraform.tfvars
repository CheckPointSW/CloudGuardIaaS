# Set in this file your deployment variables
# Specify the Azure values
azure-client-id                 = "PLEASE ENTER AZURE CLIENT ID"                                   # "xxxxx-xxxxx-xxxxx-xxxxx"
azure-client-secret             = "PLEASE ENTER AZURE CLIENT SECRET"                               # "xxxxx-xxxxx-xxxxx-xxxxx"
azure-subscription              = "PLEASE ENTER AZURE SUBSCRIPTION"                                # "xxxxx-xxxxx-xxxxx-xxxxx"
azure-tenant                    = "PLEASE ENTER AZURE TENANT"                                      # "xxxxx-xxxxx-xxxxx-xxxxx"

# Specify where you want to deploy it and where you are coming from
location                        = "PLEASE ENTER LOCATION"                                          # "France Central"
my-pub-ip                       = "PLEASE ENTER PUBLIC IP"                                         # "x.x.x.x/32"

# Management details
mgmt-sku-enabled                = "PLEASE ENTER true or false"                                     # false      # Have you ever deployed a R81.10 CKP management? Set to false if not
mgmt-dns-suffix                 = "PLEASE ENTER MANAGEMENT DNS SUFFIX"                             # "xxxxx"
mgmt-admin-pwd                  = "PLEASE ENTER MANAGEMENT ADMIN PASSWORD"                         # "xxxxx"

# VMspoke details
vmspoke-sku-enabled             = "PLEASE ENTER true or false"                                     # false      # Have you ever deployed a Nginx VM before? set to false if not
vmspoke-usr                     = "PLEASE ENTER VMSPOKE USER"                                      # "xxxxx"
vmspoke-pwd                     = "PLEASE ENTER VMSPOKE PASSWORD"                                  # "xxxxx"

# Cluster Details
cpcluster-sku-enabled           = "PLEASE ENTER true or false"                                     # false     # Have you ever deployed a R80.40 CKP cluster? set to false if not"
admin_username                  = "PLEASE ENTER ADMIN USERNAME"                                    # "xxxxx"
admin_password                  = "PLEASE ENTER ADMIN PASSWORD"                                    # "xxxxx"
sic_key                         = "PLEASE ENTER SIC KEY"                                           # "xxxxx"

# GWLB VMSS Details
gwlb-vmss-agreement             = "PLEASE ENTER true or false"                                     # false      # Have you ever deployed a GWLB VMSS? set to false if not
chkp-admin-pwd                  = "PLEASE ENTER CHKP ADMIN PASSWORD"                               # "xxxxx"
chkp-sic                        = "PLEASE ENTER CHKP SIC"                                          # "xxxxx"
