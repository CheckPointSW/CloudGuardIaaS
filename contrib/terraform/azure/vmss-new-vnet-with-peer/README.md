# Check Point CloudGuard IaaS VMSS Terraform deployment for Azure

This Terraform module deploys Check Point CloudGuard IaaS VMSS solution and connects it to an existing management server deployed in Azure. It is assumed that the management server is already created and is deployed into its own Resource-Group / vNET.
Furthermore, it is assumed that the management server is configured with a security policy and with the CME (Cloud Management Extension) service to automatically configure the VMSS when it shows up. 


## Topology Diagram
![Topology](images/Topology-2.JPG)

As part of the deployment the following resources are created:
- Resource group
- Virtual network
- Network security group
- vNET peering between VMSS new vNET and between existing management vNET
- VM Scalability Set of Check Point R80.40 gateways 

See the [Virtual Machine Scale Sets (VMSS) for Microsoft Azure R80.10 and above Administration Guide](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_VMSS_for_Azure/Content/Topics/Overview.htm) 

This solution uses the following modules:
- /cgi-terraform/azure/modules/common - used for creating a resource group and defining common variables.
- /cgi-terraform/azure/modules/vnet - used for creating new virtual network and subnets.
- /cgi-terraform/azure/modules/network-security-group - used for creating new network security groups and rules.


## Configurations
- Install and configure Terraform to provision Azure resources: [Configure Terraform for Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)
This module assumes you authenticate using Service Principlan Name (SPN) 
For security best practices reasons, the SPN credentials were removed from the terraform.tfvars file
It is advised you have the credentials as part of the environment variables of your shell.

One example is adding the below to the end of .bashrc on your host (replacing the "x" with the respective information 

  export ARM_CLIENT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx"
  
  export ARM_CLIENT_SECRET="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  
  export ARM_SUBSCRIPTION_ID="xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  
  export ARM_TENANT_ID="xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

Another option, is to have a text file (e.g. app-env) with the above text in it and run the "source" command to inject environment variables every time before executing the terraform script (i.e. "source app-env")

## Usage
- Create a Service Principal with the following permissions to the Azure subscription. 
This service principal will be used by Terraform in order to deploy the solution.
- Fill all variables in the /cgi-terraform/azure/vmss-new-vnet/terraform.tfvars file with proper values (see below for variables descriptions).
- From a command line initialize the Terraform configuration directory:

        terraform init
- Create an execution plan:
 
        terraform plan
- Create or modify the deployment:
 
        terraform apply

### terraform.tfvars variables:
 | Name          | Description   | Type          | Allowed values |
 | ------------- | ------------- | ------------- | -------------  |
 | **resource_group_name** | The name of the resource group that will contain the contents of the deployment | string | Resource group names only allow alphanumeric characters, periods, underscores, hyphens and parenthesis and cannot end in a period |
 |  |  |  |  |  |
 | **location** | The name of the resource group that will contain the contents of the deployment. | string | The full list of Azure regions can be found at https://azure.microsoft.com/regions |
 |  |  |  |  |  |
 | **vmss_name** | The name of the Check Point VMSS Object | string | Only alphanumeric characters are allowed, and the name must be 1-30 characters long |
 |  |  |  |  |  |
 | **vnet_name** | The name of virtual network that will be created | string | The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens |
 |  |  |  |  |  |
 | **address_space** | The address prefixes of the virtual network | string | Valid CIDR block |
 |  |  |  |  |  |
 | **subnet_prefixes** | The address prefixes to be used for created subnets | string | The subnets need to contain within the address space for this virtual network(defined by address_space variable) |
 |  |  |  |  |  |
 | **backend_lb_IP_address** | Is a whole number that can be represented as a binary integer with no more than the number of digits remaining in the address after the given prefix| number | Starting from 5-th IP address in a subnet. For example: subnet - 10.0.1.0/24, backend_lb_IP_address = 4 , the LB IP is 10.0.1.4 |
 |  |  |  |  |  |
 | **admin_password** | The password associated with the local administrator account on each cluster member | string | Password must have 3 of the following: 1 lower case character, 1 upper case character, 1 number, and 1 special character |
 |  |  |  |  |  |
 | **sic_key** | The Secure Internal Communication one time secret used to set up trust between the cluster object and the management server | string | Only alphanumeric characters are allowed, and the value must be 12-30 characters long |
 |  |  |  |  |  |
 | **vm_size** | Specifies the size of Virtual Machine | string | "Standard_DS2_v2", "Standard_DS3_v2", "Standard_DS4_v2", "Standard_DS5_v2", "Standard_F2s", "Standard_F4s", "Standard_F8s", "Standard_F16s", "Standard_D4s_v3", "Standard_D8s_v3", "Standard_D16s_v3", "Standard_D32s_v3", "Standard_D64s_v3", "Standard_E4s_v3", "Standard_E8s_v3", "Standard_E16s_v3", "Standard_E20s_v3", "Standard_E32s_v3", "Standard_E64s_v3", "Standard_E64is_v3", "Standard_F4s_v2", "Standard_F8s_v2", "Standard_F16s_v2", "Standard_F32s_v2", "Standard_F64s_v2", "Standard_M8ms", "Standard_M16ms", "Standard_M32ms", "Standard_M64ms", "Standard_M64s", "Standard_D2_v2", "Standard_D3_v2", "Standard_D4_v2", "Standard_D5_v2", "Standard_D11_v2", "Standard_D12_v2", "Standard_D13_v2", "Standard_D14_v2", "Standard_D15_v2", "Standard_F2", "Standard_F4", "Standard_F8", "Standard_F16", "Standard_D4_v3", "Standard_D8_v3", "Standard_D16_v3", "Standard_D32_v3", "Standard_D64_v3", "Standard_E4_v3", "Standard_E8_v3", "Standard_E16_v3", "Standard_E20_v3", "Standard_E32_v3", "Standard_E64_v3", "Standard_E64i_v3", "Standard_DS11_v2", "Standard_DS12_v2", "Standard_DS13_v2", "Standard_DS14_v2", "Standard_DS15_v2" |
 |  |  |  |  |  |
 | **disk_size** | Storage data disk size size(GB) | string | A number in the range 100 - 3995 (GB) |
 |  |  |  |  |  |
 | **vm_os_sku** | A sku of the image to be deployed | string |  "sg-byol" - BYOL license for R80.30 and above; <br/>"sg-ngtp-v2" - NGTP PAYG license for R80.30 only; <br/>"sg-ngtx-v2" - NGTX PAYG license for R80.30 only; <br/>"sg-ngtp" - NGTP PAYG license for R80.40 only; <br/>"sg-ngtx" - NGTX PAYG license for R80.40 only |
 |  |  |  |  |  |
 | **vm_os_offer** | Storage data disk size size(GB) | string | "check-point-cg-r8030"; <br/>"check-point-cg-r8040"; |
 |  |  |  |  |  |
 | **os_version** | GAIA OS version | string | "R80.30"; <br/>"R80.40"; |
 |  |  |  |  |  |
 | **bootstrap_script** | An optional script to run on the initial boot | string | Bootstrap script example: <br/>"touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt" <br/>The script will create bootstrap.txt file in the /home/admin/ and add 'hello word' string into it |
 |  |  |  |  |  |
 | **allow_upload_download** | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point | boolean | true; <br/>false; |
 |  |  |  |  |  |
 | **disable_password_authentication** | Specifies whether password authentication should be disabled | boolean | true; <br/>false; |
 |  |  |  |  |  |
 | **availability_zones_num** | A list of a single item of the Availability Zone which the Virtual Machine should be allocated in | string | "centralus", "eastus2", "francecentral", "northeurope", "southeastasia", "westeurope", "westus2", "eastus", "uksouth" |
 |  |  |  |  |  |
 | **minimum_number_of_vm_instances** | The minimum number of VMSS instances for this resource | number | Valid values are in the range 0 - 10 |
 |  |  |  |  |  |
 | **maximum_number_of_vm_instances** | The maximum number of VMSS instances for this resource | number | Valid values are in the range 0 - 10 |
 |  |  |  |  |  |
 | **management_name** | The name of the management server as it appears in the configuration file | string | Field cannot be empty. Only alphanumeric characters or '_'/'-' are allowed, and the name must be 1-30 characters long |
 |  |  |  |  |  |
 | **management_IP** | The IP address used to manage the VMSS instances | string | A valid IP address |
 |  |  |  |  |  |
  | **mgmt_vnet_name** | The name of the vNET in which the management server is deployed in | string | Field cannot be empty. Only alphanumeric characters or '_'/'-' are allowed, and the name must be 1-30 characters long |
 |  |  |  |  |  |
 | **mgmt_resource_group_name** | The of the Resource Group in which the management server is deployed in | string | Field cannot be empty. Only alphanumeric characters or '_'/'-' are allowed, and the name must be 1-30 characters long |
 |  |  |  |  |  |
 | **management_interface** | Manages the Gateways in the VMSS | string | "eth0" - An instance's external NIC's private IP address; <br/>"eth1" - an instance's internal NIC's private IP address |
 |  |  |  |  |  |
 | **configuration_template_name** | The configuration template name as it appears in the configuration file | string | Field cannot be empty. Only alphanumeric characters or '_'/'-' are allowed, and the name must be 1-30 characters long |
 |  |  |  |  |  |
 | **frontend_load_distribution** | The load balancing distribution method for the External Load Balancer | string | "Default" - None(5-tuple); <br/>"SourceIP" - ClientIP(2-tuple); <br/>"SourceIPProtocol" - ClientIP and protocol(3-tuple) |
 |  |  |  |  |  |
 | **backend_load_distribution** | The load balancing distribution method for the Internal Load Balancer | string | "Default" - None(5-tuple); <br/>"SourceIP" - ClientIP(2-tuple); <br/>"SourceIPProtocol" - ClientIP and protocol(3-tuple) |
 |  |  |  |  |  |
 | **notification_email** | An email address to notify about scaling operations | string | Leave empty double quotes or enter a valid email address |


## Example
    resource_group_name             = "checkpoint-vmss-terraform"
    location                        = "eastus"
    vmss_name                       = "checkpoint-vmss-terraform"
    vnet_name                       = "checkpoint-vmss-vnet"
    address_space                   = "10.0.0.0/16"
    subnet_prefixes                 = ["10.0.1.0/24","10.0.2.0/24"]
    backend_lb_IP_address           = 4
    admin_password                  = "xxxxxxxxxxxx"
    sic_key                         = "xxxxxxxxxxxx"
    vm_size                         = "Standard_D3_v2"
    disk_size                       = "110"
    vm_os_sku                       = "sg-byol"
    vm_os_offer                     = "check-point-cg-r8030"
    os_version                      = "R80.30"
    bootstrap_script                = "touch /home/admin/bootstrap.txt; echo 'hello_world' > /home/admin/bootstrap.txt"
    allow_upload_download           = true
    disable_password_authentication = true
    availability_zones_num          = "1"
    minimum_number_of_vm_instances  = 2
    maximum_number_of_vm_instances  = 10
    management_name                 = "mgmt"
    management_IP                   = "1.2.3.4"
    management_interface            = "eth0"
    configuration_template_name     = "vmss_template"
    notification_email              = ""
    frontend_load_distribution      = "Default"
    backend_load_distribution       = "Default"
    mgmt_vnet_name                  = "mgmt_vnet"
    mgmt_resource_group_name        = "management"
## License

See the [LICENSE](../../LICENSE) file for details

