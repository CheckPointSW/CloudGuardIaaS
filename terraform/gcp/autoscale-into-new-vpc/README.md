# Check Point Autoscale (MIG) Terraform module for GCP

Terrafrom module which deploys an Auto Scaling Group of Check Point Security Gateways into a new VPC on GCP.

These types of Terraform resources are supported:
* [Network](https://www.terraform.io/docs/providers/google/d/compute_network.html)
* [Subnetwork](https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html)
* [Instance Template](https://www.terraform.io/docs/providers/google/r/compute_instance_template.html)
* [Firewall](https://www.terraform.io/docs/providers/google/r/compute_firewall.html) - conditional creation
* [Instance Group Manager](https://www.terraform.io/docs/providers/google/r/compute_region_instance_group_manager.html)
* [Autoscaler](https://www.terraform.io/docs/providers/google/r/compute_region_autoscaler.html)


See Check Point's documentation for Autoscale (MIG) [here](https://sc1.checkpoint.com/documents/R80.30/WebAdminGuides/EN/CP_R80.30_and_Above_CG_Autoscaling_Managed_Instance_Group_for_GCP/AdminGuide/Content/Overview.htm)

This solution uses the following modules:
- /gcp/autoscale-into-existing-vpc

Terraform is controlled via a very easy to use command-line interface (CLI). Terraform is only a single command-line application: **terraform**. 

## Before you begin
1. Create a project in the [Google Cloud Console](https://console.cloud.google.com/) and set up billing on that project.
2. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) and read the Terraform getting started guide that follows. This guide will assume basic proficiency with Terraform - it is an introduction to the Google provider.

## Configuring the Provider
The **main.tf** file includes the following provider configuration block used to configure the credentials you use to authenticate with GCP, as well as a default project and location for your resources:
```
provider "google" {
  credentials = file(var.service_account_path)
  project     = var.project
  region      = var.region
}
...
```
1. [Create a Service Account](https://cloud.google.com/docs/authentication/getting-started) (or use the existing one). Next, download the JSON key file. Name it something you can remember and store it somewhere secure on your machine. <br/>
2. Select "Editor" Role or verify you have the following permissions:
    ```
    compute.autoscalers.create
    compute.autoscalers.delete
    compute.autoscalers.get
    compute.disks.create
    compute.disks.delete
    compute.firewalls.create
    compute.firewalls.delete
    compute.firewalls.get
    compute.images.get
    compute.images.useReadOnly
    compute.instanceGroupManagers.create
    compute.instanceGroupManagers.delete
    compute.instanceGroupManagers.get
    compute.instanceGroupManagers.use
    compute.instanceTemplates.create
    compute.instanceTemplates.delete
    compute.instanceTemplates.get
    compute.instanceTemplates.useReadOnly
    compute.instances.create
    compute.instances.delete
    compute.instances.setMetadata
    compute.instances.setTags
    compute.networks.create
    compute.networks.delete
    compute.networks.get
    compute.networks.updatePolicy
    compute.regions.list
    compute.subnetworks.create
    compute.subnetworks.delete
    compute.subnetworks.get
    compute.subnetworks.use
    compute.subnetworks.useExternalIp
    iam.serviceAccountKeys.get
    iam.serviceAccountKeys.list
    iam.serviceAccounts.actAs
    iam.serviceAccounts.get
    iam.serviceAccounts.list
    ```
3. ```credentials``` - Your service account key file is used to complete a two-legged OAuth 2.0 flow to obtain access tokens to authenticate with the GCP API as needed; Terraform will use it to reauthenticate automatically when tokens expire. <br/> 
The provider credentials can be provided either as static credentials or as [Environment Variables](https://www.terraform.io/docs/providers/google/guides/provider_reference.html#credentials-1).
    - Static credentials can be provided by adding the path to your service-account json file, project-name and region in /gcp/modules/autoscale-into-new-vpc/**terraform.tfvars** file as follows:
        ```
        service_account_path = "service-accounts/service-account-file-name.json"
        project = "project-name"
        region = "us-central1"
        ```
     - In case the Environment Variables are used, perform modifications described below:<br/>
        a. The next lines in the main.tf file, in the provider google resource, need to be deleted or commented:
        ```
        provider "google" {
          //  credentials = file(var.service_account_path)
          //  project = var.project
       
          region = var.region
        }
       ```
       b.In the terraform.tfvars file leave empty double quotes for credentials and project variables:
       ```
       service_account_path = ""
       project = ""
       ```
    ## Usage
- Fill all variables in the /gcp/autoscale-into-new-vpc/**terraform.tfvars** file with proper values (see below for variables descriptions).
- From a command line initialize the Terraform configuration directory:
    ```
    terraform init
    ```
- Create an execution plan:
    ```
    terraform plan
    ```
- Create or modify the deployment:
    ```
    terraform apply
    ```
  
#### Variables are configured in autoscale-into-new-vpc/**terraform.tfvars** file as follows:
```
# --- Google Provider ---
service_account_path = "service-accounts/service-account-file-name.json"
project = "project-name"

# --- Check Point---
prefix = "chkp-tf-mig"
license = "BYOL"
image_name = "check-point-r8040-gw-byol-mig-123-456-v12345678"
management_nic = "Ephemeral Public IP (eth0)"
management_name = "tf-checkpoint-management"
configuration_template_name = "tf-asg-autoprov-tmplt"
admin_SSH_key = "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
network_defined_by_routes = true
admin_shell = "/etc/cli.sh"
allow_upload_download = true

# --- Networking ---
region = "us-central1"
external_subnetwork_ip_cidr_range = "10.0.1.0/24"
internal_subnetwork_ip_cidr_range = "10.0.2.0/24"
ICMP_traffic = ["123.123.0.0/24", "234.234.0.0/24"]
TCP_traffic = ["0.0.0.0/0"]
UDP_traffic = []
SCTP_traffic = []
ESP_traffic = []

# --- Instance Configuration ---
machine_type = "n1-standard-4"
cpu_usage = 60
instances_min_grop_size = 2
instances_max_grop_size = 10
disk_type = "SSD Persistent Disk"
disk_size = 100
enable_monitoring = false
```

- To tear down your resources:
    ```
    terraform destroy
    ```

## Conditional creation
To create Firewall and allow traffic for ICMP, TCP, UDP, SCTP or/and ESP - enter list of Source IP ranges.
```
ICMP_traffic = ["123.123.0.0/24", "234.234.0.0/24"]
TCP_traffic = ["0.0.0.0/0"]
UDP_traffic = []
SCTP_traffic = []
ESP_traffic = []
```
Please leave empty list to which port you want to unable traffic.

## Inputs
| Name          | Description   | Type          | Allowed values | Default       | Required      |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| service_account_path | User service account path in JSON format - From the service account key page in the Cloud Console choose an existing account or create a new one. Next, download the JSON key file. Name it something you can remember, store it somewhere secure on your machine, and supply the path to the location is stored. (e.g. "service-accounts/service-account-name.json")  | string  | N/A | "" | yes |
| project  | Personal project id. The project indicates the default GCP project all of your resources will be created in.  | string  | N/A | "" | yes |
|  |  |  |  |  |
| prefix | (Optional) Resources name prefix. | string | N/A | "chkp-tf-mig" | no |
| license | Checkpoint license (BYOL or PAYG). | string | - BYOL <br/> - PAYG <br/> | "BYOL" | no |
| image_name | The autoscaling (MIG) image name (e.g. check-point-r8040-gw-byol-mig-123-456-v12345678). You can choose the desired mig image value from [Github](https://github.com/CheckPointSW/CloudGuardIaaS/blob/master/gcp/deployment-packages/autoscale-byol/images.py). | string | N/A | N/A | yes |
| management_nic | Management Interface - Autoscaling Security Gateways in GCP can be managed by an ephemeral public IP or using the private IP of the internal interface (eth1). | string | Ephemeral Public IP (eth0) <br/> - Private IP (eth1) | "Ephemeral Public IP (eth0)" | no |
| management_name | The name of the Security Management Server as appears in autoprovisioning configuration. (Please enter a valid Security Management name including ascii characters only). | string | N/A | "checkpoint-management" | no |
| configuration_template_name | Specify the provisioning configuration template name (for autoprovisioning). (Please enter a valid autoprovisioing configuration template name including ascii characters only). | string | N/A | "gcp-asg-autoprov-tmplt" | no |
| admin_SSH_key | Public SSH key for the user 'admin' - The SSH public key for SSH authentication to the MIG instances. Leave this field blank to use all project-wide pre-configured SSH keys. | string | A valid public ssh key | "" | no |
| network_defined_by_routes | Set eth1 topology to define the networks behind this interface by the routes configured on the gateway. | bool | true/false | true | no |
| admin_shell | Change the admin shell to enable advanced command line configuration. | string | - /etc/cli.sh <br/> - /bin/bash <br/> - /bin/csh <br/> - /bin/tcsh | "/etc/cli.sh" | no |
| allow_upload_download | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point | bool | true/false | true | no |
|  |  |  |  |  |
| region  | GCP region  | string  | N/A | N/A  | yes |
| external_subnetwork_ip_cidr_range | The range of internal addresses that are owned by this subnetwork, only IPv4 is supported (e.g. "10.0.0.0/8" or "192.168.0.0/16"). | string | N/A | N/A | yes |
| internal_subnetwork_ip_cidr_range | The range of internal addresses that are owned by this subnetwork, only IPv4 is supported (e.g. "10.0.0.0/8" or "192.168.0.0/16"). | string | N/A | N/A | yes |
| ICMP_traffic | (Optional) Source IP ranges for ICMP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable ICMP traffic. | list(string) | N/A | [] | no |
| TCP_traffic | (Optional) Source IP ranges for TCP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable TCP traffic. | list(string) | N/A | [] | no |
| UDP_traffic | (Optional) Source IP ranges for UDP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable UDP traffic. | list(string) | N/A | [] | no |
| SCTP_traffic | (Optional) Source IP ranges for SCTP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable SCTP traffic. | list(string) | N/A | [] | no |
| ESP_traffic | (Optional) Source IP ranges for ESP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. Please leave empty list to unable ESP traffic. | list(string) | N/A | [] | no |
|  |  |  |  |  |
| machine_type | Machine Type. | string | N/A | "n1-standard-4" | no |
| cpu_usage | Target CPU usage (%) - Autoscaling adds or removes instances in the group to maintain this level of CPU usage on each instance. | number | number between 10 and 90 | 60 | no |
| instances_min_grop_size | The minimal number of instances | number | N/A | 2 | no |
| instances_max_grop_size | The maximal number of instances | number | N/A | 10 | no |
| disk_type | Storage space is much less expensive for a standard Persistent Disk. An SSD Persistent Disk is better for random IOPS or streaming throughput with low latency. | string | - SSD Persistent Disk <br/> - Balanced Persistent Disk <br/> - Standard Persistent Disk | "SSD Persistent Disk" | no |
| disk_size | Disk size in GB - Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space. | number | number between 100 and 4096 | 100 | no |
| enable_monitoring | Enable Stackdriver monitoring | bool | true/false | false | no |



## Outputs
| Name  | Description |
| ------------- | ------------- |
| external_network_name  | The external network name in which the gateways will reside.  |
| external_subnetwork_name  | The external subnetwork name.  |
| internal_network_name  | The internal network name in which application servers reside.  |
| internal_subnetwork_name  | The internal subnetwork name.  |
| SIC_key  | Secure Internal Communication (SIC) initiation key.  |
| management_name  | Security Management server name.  |
| configuration_template_name  | Provisioning configuration template name.  |
| instance_template_name  | Instance template name.  |
| instance_group_manager_name  | Instance group manager name.  |
| autoscaler_name  | Autoscaler name.  |
| ICMP_firewall_rules_name  | If enable - the ICMP firewall rules name, otherwise, an empty list.  |
| TCP_firewall_rules_name  | If enable - the TCP firewall rules name, otherwise, an empty list.  |
| UDP_firewall_rules_name  | If enable - the UDP firewall rules name, otherwise, an empty list.  |
| SCTP_firewall_rules_name  | If enable - the SCTP firewall rules name, otherwise, an empty list.  |
| ESP_firewall_rules_name  | If enable - the ESP firewall rules name, otherwise, an empty list.  |
 
## Revision History
In order to check the template version refer to the [sk116585](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk116585)

| Template Version | Description   |
| ---------------- | ------------- |
| 20201208 | First release of Check Point CloudGuard IaaS Auto Scaling Group of Check Point Security Gateways Terraform solution into a new VPC on GCP. |
| | | |

## Authors


## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details
