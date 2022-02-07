# CloudGuard GWLB Deployment on Azure
This Terraform project is intended to be used as a template in a demonstration or to build a test environment.  
What it does is creating an infrastructure composed of three directly exposed application, and protect them with a VMSS CloudGuard deployment by using the newly launched Azure GWLB service. These applications will have then the East-West traffic protected by a CloudGuard HA Cluster.    

## Disclaimer
Please note that GWLB service is today in Preview and therefore not reccomanded for production workload.     
You can review the support statement at:     
1. Microsoft Azure public documentation: [Documentation Link](https://docs.microsoft.com/en-us/azure/load-balancer/gateway-overview)
2. Check Point public documentation: [Documentation Link](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_Azure_VMSS_GWLB/Content/Topics-Azure-VMSS-GWLB/Public-Preview-Disclaimer.htm?tocpath=_____3#Public_Preview_Disclaimer)

## Do you want to see more?    
Check out other CloudGuard examples at [Github/gbrembati](https://github.com/gbrembati/)

## Which are the components created?
The project creates the following resources and combine them:
1. **Resource Groups**: for the vnets, the management and the spokes
2. **Vnet**: north / south / mgmt / spokes
3. **Subnets**: inside the vNets
4. **Vnet peerings** (as shown in the design below)
5. **Routing table**: associated with the network in the spokes
6. **Rules** for the routing tables created
7. **Network Security Groups**: associated with nets and VMs
8. **NSG Rules** inside the differents NSGs: to prevent undesired connections
9. **Check Point Instances**: A Check Point R80.40 Cluster, R81.10 Management, R81.10 VMSS GWLB
10. **Public IPs**: associated with the management and the spoke VMs)
11. **Create DNS zone**: used later on to have the application easily accessible
12. **Created 3 web application**: it builds three application directly accessible with Public IPs or Public LBs
13. **Integrates GWLB with Application**: the deployed GWLB is set to protect the web applications

## How to use it
The only thing that you need to do is changing the __*terraform.tfvars*__ file located in this directory.

```hcl
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
```
If you want (or need) to further customize other project details, you can change defaults in the different __*name-variables.tf*__ files.   
Here you will also able to find the descriptions that explains what each variable is used for.

## The infrastruction created with the following design:
![Architectural Design](/zimages/azure-gwlb-design.jpg)