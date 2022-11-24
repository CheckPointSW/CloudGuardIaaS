# Check Point CloudGuard IaaS High Availability Terraform deployment for Azure

This Terraform module deploys Check Point CloudGuard IaaS High Availability solution into an existing Vnet in Azure.
As part of the deployment the following resources are created:
- Resource group
- System assigned identity
- Availability Set - conditional creation

See the [Check Point CloudGuard IaaS High Availability for Azure Administration Guide](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_IaaS_HighAvailability_for_Azure/Content/Topics/Check_Point_CloudGuard_IaaS_High_Availability_for_Azure.htm) for additional information

This solution uses the following modules:
- /terraform/azure/modules/common - used for creating a resource group and defining common variables.


## Configurations
- Install and configure Terraform to provision Azure resources: [Configure Terraform for Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)
- In order to use ssh connection to VMs, it is **required** to add a public key to the /terraform/azure/high-availability-existing-vnet/azure_public_key file.

## Usage
- Choose the preferred login method to Azure in order to deploy the solution:
    <br>1. Using Service Principal:
    - Create a [Service Principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) (or use the existing one) 
    - Grant the Service Principal at least "**Owner**" permissions to the Azure subscription<br>
    - The Service Principal credentials can be stored either in the terraform.tfvars or as [Environment Variables](https://www.terraform.io/docs/providers/azuread/guides/service_principal_client_secret.html)<br>
    
      In case the Environment Variables are used, perform modifications described below:<br>
      
       a. The next lines in the main.tf file, in the provider azurerm resource,  need to be deleted or commented:
            
                provider "azurerm" {
                
                //  subscription_id = var.subscription_id
                //  client_id = var.client_id
                //  client_secret = var.client_secret
                //  tenant_id = var.tenant_id
                
                   features {}
                }
            
        b. In the terraform.tfvars file leave empty double quotes for client_secret, client_id , tenant_id and subscription_id variables:
        
                client_secret                   = ""
                client_id                       = ""
                tenant_id                       = ""
                subscription_id                 = "" 
        
    <br>2. Using **az** commands from a command-line:
    - Run  **az login** command 
    - Sign in with your account credentials in the browser
    - [Accept Azure Marketplace image terms](https://docs.microsoft.com/en-us/cli/azure/vm/image/terms?view=azure-cli-latest) by running:
     <br>**az vm image terms accept --urn publisher:offer:sku:version**, where:
        - publisher = checkpoint;
        - offer = vm_os_offer (see accepted values in the table below);
        - sku = vm_os_sku (see accepted values in the table below);
        - version = latest<br/>
    <br>Example:<br>
    az vm image terms accept --urn checkpoint:check-point-cg-r8040:sg-byol:latest
    
    - In the terraform.tfvars file leave empty double quotes for client_secret, client_id and tenant_id variables. 
 
- Fill all variables in the /terraform/azure/high-availability-existing-vnet/terraform.tfvars file with proper values (see below for variables descriptions).
- From a command line initialize the Terraform configuration directory:

        terraform init
- Create an execution plan:
 
        terraform plan
- Create or modify the deployment:
 
        terraform apply

### terraform.tfvars variables:
 | Name          | Description   | Type          | Allowed values |
 | ------------- | ------------- | ------------- | -------------  |
 | **client_secret** | passwordThe client secret of the Service Principal used to deploy the solution | string |
 |  |  |  |  |  |
 | **client_id** | The client ID of the Service Principal used to deploy the solution | string |
 |  |  |  |  |  |
 | **tenant_id** | The tenant ID of the Service Principal used to deploy the solution | string |
 |  |  |  |  |  |
 | **subscription_id** | The subscription ID is used to pay for Azure cloud services | string |
 |  |  |  |  |  |
 | **source_image_vhd_uri** | The URI of the blob containing the development image. Please use noCustomUri if you want to use marketplace images. | string | 
 |  |  |  |  |  |
 | **resource_group_name** | The name of the resource group that will contain the contents of the deployment | string | Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis and cannot end in a period |
 |  |  |  |  |  |
 | **location** | The name of the resource group that will contain the contents of the deployment. | string | The full list of Azure regions can be found at https://azure.microsoft.com/regions |
 |  |  |  |  |  |
 | **cluster_name** | The name of the Check Point Cluster Object | string | Only alphanumeric characters are allowed, and the name must be 1-30 characters long |
 |  |  |  |  |  |
 | **vnet_name** | Virtual Network name | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens |
 |  |  |  |  |  |
 | **vnet_resource_group** | Resource Group of the existing virtual network | string | The exact name of the existing vnet's resource group |
 |  |  |  |  |  |
 | **frontend_subnet_name** | Specifies the name of the external subnet | string | The exact name of the existing external subnet |
 |  |  |  |  |  |
 | **backend_subnet_name** | Specifies the name of the internal subnet | string | The exact name of the existing internal subnet |
 |  |  |  |  |  |
 | **frontend_IP_addresses** | A list of three whole numbers representing the private ip addresses of the members eth0 NICs and the cluster vip ip addresses. The numbers can be represented as binary integers with no more than the number of digits remaining in the address after the given frontend subnet prefix. The IP addresses are defined by their position in the frontend subnet. | list(number) | 
 |  |  |  |  |  |
 | **backend_IP_addresses** | A list of three whole numbers representing the private ip addresses of the members eth1 NICs and the backend lb ip addresses. The numbers can be represented as binary integers with no more than the number of digits remaining in the address after the given backend subnet prefix. The IP addresses are defined by their position in the backend subnet. | list(number) | 
 |  |  |  |  |  |
 | **admin_password** | The password associated with the local administrator account on each cluster member | string | Password must have 3 of the following: 1 lower case character, 1 upper case character, 1 number, and 1 special character |
 |  |  |  |  |  |
 | **sic_key** | The Secure Internal Communication one time secret used to set up trust between the cluster object and the management server | string | Only alphanumeric characters are allowed, and the value must be 12-30 characters long |
 |  |  |  |  |  |
 | **vm_size** | Specifies the size of Virtual Machine | string | "Standard_DS2_v2", "Standard_DS3_v2", "Standard_DS4_v2", "Standard_DS5_v2", "Standard_F2s", "Standard_F4s", "Standard_F8s", "Standard_F16s", "Standard_D4s_v3", "Standard_D8s_v3", "Standard_D16s_v3", "Standard_D32s_v3", "Standard_D64s_v3", "Standard_E4s_v3", "Standard_E8s_v3", "Standard_E16s_v3", "Standard_E20s_v3", "Standard_E32s_v3", "Standard_E64s_v3", "Standard_E64is_v3", "Standard_F4s_v2", "Standard_F8s_v2", "Standard_F16s_v2", "Standard_F32s_v2", "Standard_F64s_v2", "Standard_M8ms", "Standard_M16ms", "Standard_M32ms", "Standard_M64ms", "Standard_M64s", "Standard_D2_v2", "Standard_D3_v2", "Standard_D4_v2", "Standard_D5_v2", "Standard_D11_v2", "Standard_D12_v2", "Standard_D13_v2", "Standard_D14_v2", "Standard_D15_v2", "Standard_F2", "Standard_F4", "Standard_F8", "Standard_F16", "Standard_D4_v3", "Standard_D8_v3", "Standard_D16_v3", "Standard_D32_v3", "Standard_D64_v3", "Standard_E4_v3", "Standard_E8_v3", "Standard_E16_v3", "Standard_E20_v3", "Standard_E32_v3", "Standard_E64_v3", "Standard_E64i_v3", "Standard_DS11_v2", "Standard_DS12_v2", "Standard_DS13_v2", "Standard_DS14_v2", "Standard_DS15_v2" |
 |  |  |  |  |  |
 | **disk_size** | Storage data disk size size(GB) | string | A number in the range 100 - 3995 (GB) |
 |  |  |  |  |  |
 | **vm_os_sku** | A sku of the image to be deployed | string |  "sg-byol" - BYOL license for R80.40 and above; <br/>"sg-ngtp" - NGTP PAYG license for R80.40 and above; <br/>"sg-ngtx" - NGTX PAYG license for R80.40 and above; |
 |  |  |  |  |  |
 | **vm_os_offer** | The name of the image offer to be deployed | string | "check-point-cg-r8040"; <br/>"check-point-cg-r81"; <br/>"check-point-cg-r81.10"; <br/>"check-point-cg-r81.20"; |
 |  |  |  |  |  |
 | **os_version** | GAIA OS version | string | "R80.40"; <br/>"R81"; <br/>"R81.10"; <br/>"R81.20"; |
 |  |  |  |  |  |
 | **bootstrap_script** | An optional script to run on the initial boot | string | Bootstrap script example: <br/>"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt" <br/>The script will create bootstrap.txt file in the /home/admin/ and add 'hello word' string into it |
 |  |  |  |  |  |
 | **allow_upload_download** | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point | boolean | true; <br/>false; |
 |  |  |  |  |  |
 | **authentication_type** | Specifies whether a password authentication or SSH Public Key authentication should be used | string | "Password"; <br/>"SSH Public Key"; |
 |  |  |  |  |  |
 | **availability_type** | Specifies whether to deploy the solution based on Azure Availability Set or based on Azure Availability Zone. | string | "Availability Zone"; <br/>"Availability Set"; |
 |  |  |  |  |  |
 | **enable_custom_metrics** | Indicates whether CloudGuard Metrics will be use for Cluster members monitoring. | boolean | true; <br/>false; |
 |  |  |  |  |  |
 | **enable_floating_ip** | Indicates whether the load balancers will be deployed with floating IP. | boolean | true; <br/>false; |
 |  |  |  |  |  |
 | **use_public_ip_prefix** | Indicates whether the public IP resources will be deployed with public IP prefix. | boolean | true; <br/>false; |
 |  |  |  |  |  |
 | **create_public_ip_prefix** | Indicates whether the public IP prefix will created or an existing will be used. | boolean | true; <br/>false; |
 |  |  |  |  |  |
 | **existing_public_ip_prefix_id** | The existing public IP prefix resource id. | string | Existing public IP prefix resource id |
 |  |  |  |  |  |
 | **admin_shell** | Enables to select different admin shells | string | /etc/cli.sh; <br/>/bin/bash; <br/>/bin/csh; <br/>/bin/tcsh; |

## Conditional creation
- To deploy the solution based on Azure Availability Set and create a new Availability Set for the virtual machines:
```
availability_type = "Availability Set"
```
 Otherwise, to deploy the solution based on Azure Availability Zone:
```
availability_type = "Availability Zone"
```
-  To enable CloudGuard metrics in order to send statuses and statistics collected from HA instances to the Azure Monitor service:
  ```
  enable_custom_metrics = true
  ```
- To create new public IP prefix for the public IP:
  ```
  use_public_ip_prefix            = true
  create_public_ip_prefix         = true
  ```
- To use an existing public IP prefix for the public IP:
  ```
  use_public_ip_prefix            = true
  create_public_ip_prefix         = false
  existing_public_ip_prefix_id    = "public IP prefix resource id"
  ```

## Example
    client_secret                   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    client_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    tenant_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    subscription_id                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    source_image_vhd_uri            = "noCustomUri"
    resource_group_name             = "checkpoint-ha-terraform"
    cluster_name                    = "checkpoint-ha-terraform"
    location                        = "eastus"
    vnet_name                       = "checkpoint-ha-vnet"
    vnet_resource_group             = "existing-vnet"
    frontend_subnet_name            = "frontend"
    backend_subnet_name             = "backend"
    frontend_IP_addresses           = [5, 6, 7]
    backend_IP_addresses            = [5, 6, 7]
    admin_password                  = "xxxxxxxxxxxx"
    sic_key                         = "xxxxxxxxxxxx"
    vm_size                         = "Standard_D3_v2"
    disk_size                       = "110"
    vm_os_sku                       = "sg-byol"
    vm_os_offer                     = "check-point-cg-r8110"
    os_version                      = "R81.10"
    bootstrap_script                = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
    allow_upload_download           = true
    authentication_type             = "Password"
    availability_type               = "Availability Zone"
    enable_custom_metrics           = true
    enable_floating_ip              = false
    use_public_ip_prefix            = false
    create_public_ip_prefix         = false
    existing_public_ip_prefix_id    = ""
    admin_shell                     = "/etc/cli.sh"
    
## Revision History
In order to check the template version refer to the [sk116585](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk116585)

| Template Version | Description   |
| ---------------- | ------------- |
| 20221124 | - Added R81.20 support   <br/> - Upgraded azurerm provider |
| | | |
| 20220111 | - Added support to select different shells. |
| | | |
| 20210309 | - Add "source_image_vhd_uri" variable for using a custom development image |
| | | |
| 20210111 | First release of Check Point CloudGuard IaaS High Availability Terraform deployment into an existing Vnet in Azure. |
| | | |
|  | Addition of "templateType" parameter to "cloud-version" files. |
| | | |

## License

See the [LICENSE](../../LICENSE) file for details

