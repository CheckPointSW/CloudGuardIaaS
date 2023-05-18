# Check Point CloudGuard IaaS Management Terraform deployment for Azure

This Terraform module deploys Check Point CloudGuard IaaS Management solution into an existing Vnet in Azure.
As part of the deployment the following resources are created:
- Resource group
- Network security group
- Virtual Machine
- System assigned identity

This solution uses the following modules:
- /terraform/azure/modules/common - used for creating a resource group and defining common variables.
- /terraform/azure/modules/network-security-group - used for creating new network security groups and rules.


## Configurations
- Install and configure Terraform to provision Azure resources: [Configure Terraform for Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)
- In order to use ssh connection to VMs, it is **required** to add a public key to the /terraform/azure/management-existing-vnet/azure_public_key file.

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
 
- Fill all variables in the /terraform/azure/management-existing-vnet/terraform.tfvars file with proper values (see below for variables descriptions).
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
 | **mgmt_name** | Management name. | string |  
 |  |  |  |  |  |
 | **location** | The region where the resources will be deployed at. | string | The full list of Azure regions can be found at https://azure.microsoft.com/regions |
 |  |  |  |  |  |
 | **vnet_name** | Virtual Network name | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens |
 |  |  |  |  |  |
 | **vnet_resource_group** | Resource Group of the existing virtual network | string | The exact name of the existing vnet's resource group |
 |  |  |  |  |  |
 | **management_subnet_name** | Management subnet name | string | The exact name of the existing subnet |
 |  |  |  |  |  |
 | **subnet_1st_Address** | The first available address of the subnet | string | 
 |  |  |  |  |  |
 | **management_GUI_client_network** | Allowed GUI clients - GUI clients network CIDR. | string | 
 |  |  |  |  |  |
 | **mgmt_enable_api** | Enable api access to the management. | string | - "all"; <br/> - "management_only"; <br/> - "gui_clients" <br/> - "disable";
 |  |  |  |  |  |
 | **admin_password** | The password associated with the local administrator account on each cluster member | string | Password must have 3 of the following: 1 lower case character, 1 upper case character, 1 number, and 1 special character |
 |  |  |  |  |  |
 | **vm_size** | Specifies the size of Virtual Machine | string | "Standard_DS2_v2", "Standard_DS3_v2", "Standard_DS4_v2", "Standard_DS5_v2", "Standard_F2s", "Standard_F4s", "Standard_F8s", "Standard_F16s", "Standard_D4s_v3", "Standard_D8s_v3", "Standard_D16s_v3", "Standard_D32s_v3", "Standard_D64s_v3", "Standard_E4s_v3", "Standard_E8s_v3", "Standard_E16s_v3", "Standard_E20s_v3", "Standard_E32s_v3", "Standard_E64s_v3", "Standard_E64is_v3", "Standard_F4s_v2", "Standard_F8s_v2", "Standard_F16s_v2", "Standard_F32s_v2", "Standard_F64s_v2", "Standard_M8ms", "Standard_M16ms", "Standard_M32ms", "Standard_M64ms", "Standard_M64s", "Standard_D2_v2", "Standard_D3_v2", "Standard_D4_v2", "Standard_D5_v2", "Standard_D11_v2", "Standard_D12_v2", "Standard_D13_v2", "Standard_D14_v2", "Standard_D15_v2", "Standard_F2", "Standard_F4", "Standard_F8", "Standard_F16", "Standard_D4_v3", "Standard_D8_v3", "Standard_D16_v3", "Standard_D32_v3", "Standard_D64_v3", "Standard_E4_v3", "Standard_E8_v3", "Standard_E16_v3", "Standard_E20_v3", "Standard_E32_v3", "Standard_E64_v3", "Standard_E64i_v3", "Standard_DS11_v2", "Standard_DS12_v2", "Standard_DS13_v2", "Standard_DS14_v2", "Standard_DS15_v2" |
 |  |  |  |  |  |
 | **disk_size** | Storage data disk size size(GB) | string | A number in the range 100 - 3995 (GB) |
 |  |  |  |  |  |
 | **vm_os_sku** | A sku of the image to be deployed | string | "mgmt-byol" - BYOL license for R80.40 and above; <br/>"mgmt-25" - PAYG for R80.40 and above; |
 |  |  |  |  |  |
 | **vm_os_offer** | The name of the image offer to be deployed | string | "check-point-cg-r8040"; <br/>"check-point-cg-r81"; <br/>"check-point-cg-r8110"; <br/>"check-point-cg-r8120"; |
 |  |  |  |  |  |
 | **os_version** | GAIA OS version | string | "R80.40"; <br/>"R81"; <br/>"R81.10"; <br/>"R81.20";|
 |  |  |  |  |  |
 | **bootstrap_script** | An optional script to run on the initial boot | string | Bootstrap script example: <br/>"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt" <br/>The script will create bootstrap.txt file in the /home/admin/ and add 'hello word' string into it |
 |  |  |  |  |  |
 | **allow_upload_download** | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point | boolean | true; <br/>false; |
 |  |  |  |  |  |
 | **authentication_type** | Specifies whether a password authentication or SSH Public Key authentication should be used | string | "Password"; <br/>"SSH Public Key"; |
 |  |  |  |  |  |
 | **admin_shell** | Enables to select different admin shells | string | /etc/cli.sh; <br/>/bin/bash; <br/>/bin/csh; <br/>/bin/tcsh; |



## Example
    client_secret                   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    client_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    tenant_id                       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    subscription_id                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    source_image_vhd_uri            = "noCustomUri"
    resource_group_name             = "checkpoint-mgmt-terraform"
    mgmt_name                       = "checkpoint-mgmt-terraform"
    location                        = "eastus"
    vnet_name                       = "checkpoint-mgmt-vnet"
    vnet_resource_group             = "existing-vnet"
    management_subnet_name          = "mgmt-subnet"
    subnet_1st_Address              = "10.0.1.4"
    management_GUI_client_network   = "0.0.0.0/0"
    mgmt_enable_api                 = "disable"
    admin_password                  = "xxxxxxxxxxxx"
    vm_size                         = "Standard_D3_v2"
    disk_size                       = "110"
    vm_os_sku                       = "mgmt-byol"
    vm_os_offer                     = "check-point-cg-r8110"
    os_version                      = "R81.10"
    bootstrap_script                = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
    allow_upload_download           = true
    authentication_type             = "Password"
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
| 20210111 | First release of Check Point CloudGuard IaaS Management Terraform deployment into an existing Vnet in Azure. |
| | | |
|  | Addition of "templateType" parameter to "cloud-version" files. |
| | | |

## License

See the [LICENSE](../../LICENSE) file for details

