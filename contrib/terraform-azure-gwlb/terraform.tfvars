# Set in this file your deployment variables
# Specify the Azure values
azure-client-id     = "xxxxx-xxxxx-xxxxx-xxxxx"
azure-client-secret = "xxxxx-xxxxx-xxxxx-xxxxx"
azure-subscription  = "xxxxx-xxxxx-xxxxx-xxxxx"
azure-tenant        = "xxxxx-xxxxx-xxxxx-xxxxx"

# Specify where you want to deploy it and where you are coming from
location                = "France Central"
my-pub-ip               = "x.x.x.x/32"

# Management details
mgmt-sku-enabled        = false      # Have you ever deployed a R81.10 CKP management? Set to false if not
mgmt-dns-suffix         = "xxxxx"
mgmt-admin-pwd          = "xxxxx"

# VMspoke details
vmspoke-sku-enabled     = false      # Have you ever deployed a Nginx VM before? set to false if not
vmspoke-usr             = "xxxxx"
vmspoke-pwd             = "xxxxx"

# Cluster Details
cpcluster-sku-enabled   = false     # Have you ever deployed a R80.40 CKP cluster? set to false if not"
admin_username          = "xxxxx"
admin_password          = "xxxxx"
sic_key                 = "xxxxx"

# GWLB VMSS Details
gwlb-vmss-agreement     = false      # Have you ever deployed a GWLB VMSS? set to false if not
chkp-admin-pwd          = "xxxxx"
chkp-sic                = "xxxxx"
