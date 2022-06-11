# Check Point Cluster High Availability (HA) Terraform module for GCP

Terraform module which deploys Check Point CloudGuard IaaS High Availability solution on GCP.

These types of Terraform resources are supported:
* [Network](https://www.terraform.io/docs/providers/google/d/compute_network.html) - conditional creation
* [Subnetwork](https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html) - conditional creation
* [Instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)
* [IP address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_address)
* [Firewall](https://www.terraform.io/docs/providers/google/r/compute_firewall.html) - conditional creation


See Check Point's documentation for Cluster High Availability (HA) [here](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_IaaS_HighAvailabilty_for_GCP/Default.htm)

This solution uses the following modules:
- \gcp\common\network-and-subnet
- \gcp\common\firewall-rule
- \gcp\common\cluster-member
- \gcp\common\members-a-b

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
    compute.addresses.create
    compute.addresses.delete
    compute.addresses.get
    compute.addresses.use
    compute.disks.create
    compute.firewalls.create
    compute.firewalls.delete
    compute.firewalls.get
    compute.images.get
    compute.images.useReadOnly
    compute.instances.create
    compute.instances.delete
    compute.instances.get
    compute.instances.setMetadata
    compute.instances.setServiceAccount
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
    compute.zones.get
    iam.serviceAccountKeys.get
    iam.serviceAccountKeys.list
    iam.serviceAccounts.actAs
    iam.serviceAccounts.get
    iam.serviceAccounts.list
    ```
3. ```credentials``` - Your service account key file is used to complete a two-legged OAuth 2.0 flow to obtain access tokens to authenticate with the GCP API as needed; Terraform will use it to reauthenticate automatically when tokens expire. <br/> 
The provider credentials can be provided either as static credentials or as [Environment Variables](https://www.terraform.io/docs/providers/google/guides/provider_reference.html#credentials-1).
    - Static credentials can be provided by adding the path to your service-account json file, project-name and region in /gcp/modules/high-availability/**terraform.tfvars** file as follows:
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
- Fill all variables in the /gcp/high-availability/**terraform.tfvars** file with proper values (see below for variables descriptions).
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
  
#### Variables are configured in high-availability/**terraform.tfvars** file as follows:
```
# --- Google Provider ---
service_account_path = "service-accounts/service-account-file-name.json"
project = "project-name"

# --- Check Point Deployment ---
prefix = "chkp-tf-ha"
license = "BYOL"
image_name = "check-point-r8040-gw-byol-cluster-123-456-v12345678"

# --- Instances Configuration ---
region = "us-central1"
zoneA = "us-central1-a"
zoneB = "us-central1-a"
machine_type = "n1-standard-4"
disk_type = "SSD Persistent Disk"
disk_size = 100
admin_SSH_key = "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
enable_monitoring = false

# --- Check Point ---
management_network = "209.87.209.100/32"
sic_key = "aaaaaaaa"
generate_password = false
allow_upload_download = false
admin_shell = "/bin/bash"

# --- Networking ---
cluster_network_cidr = "10.0.1.0/24"
cluster_network_name = "cluster-network"
cluster_network_subnetwork_name = "cluster-subnetwork"
cluster_ICMP_traffic = ["0.0.0.0/0"]
cluster_TCP_traffic = ["0.0.0.0/0"]
cluster_UDP_traffic = []
cluster_SCTP_traffic = []
cluster_ESP_traffic = []
mgmt_network_cidr = ""
mgmt_network_name = "mgmt-network"
mgmt_network_subnetwork_name = "mgmt-subnetwork"
mgmt_ICMP_traffic = []
mgmt_TCP_traffic = []
mgmt_UDP_traffic = []
mgmt_SCTP_traffic = ["0.0.0.0/0"]
mgmt_ESP_traffic = ["0.0.0.0/0"]
num_internal_networks = 1
internal_network1_cidr = "10.0.3.0/24"
internal_network1_name = ""
internal_network1_subnetwork_name = ""

```

- To tear down your resources:
    ```
    terraform destroy
    ```
 

## Conditional creation
<br>1. For each network and subnet variable, you can choose whether to create a new network with a new subnet or to use an existing one.
- If you want to create a new network and subnet, please input a subnet CIDR block for the desired new network - In this case, the network name and subnetwork name will not be used:
```
    cluster_network_cidr = "10.0.1.0/24"
    cluster_network_name = "not-use"
    cluster_network_subnetwork_name = "not-use"
```
- Otherwise, if you want to use existing network and subnet, please leave empty double quotes in the CIDR variable for the desired network:
```
    cluster_network_cidr = ""
    cluster_network_name = "cluster-network"
    cluster_network_subnetwork_name = "cluster-subnetwork"
```
<br>2. To create Firewall and allow traffic for ICMP, TCP, UDP, SCTP or/and ESP - enter list of Source IP ranges.
<br>Please leave empty list for a protocol if you want to disable traffic for it.
- For cluster:
```
    cluster_ICMP_traffic = ["123.123.0.0/24", "234.234.0.0/24"]
    cluster_TCP_traffic = ["0.0.0.0/0"]
    cluster_UDP_traffic = []
    cluster_SCTP_traffic = []
    cluster_ESP_traffic = []
```
- For management:
```
    mgmt_ICMP_traffic = ["123.123.0.0/24", "234.234.0.0/24"]
    mgmt_TCP_traffic = ["0.0.0.0/0"]
    mgmt_UDP_traffic = []
    mgmt_SCTP_traffic = []
    mgmt_ESP_traffic = []
```
<br>3.The cluster members will each have a network interface in each internal network and create high priority routes that will route all outgoing traffic to the cluster member that is currently active.
<br>Using internal networks depends on the variable num_internal_networks, by selecting a number in range 1 - 6 that represents the number of internal networks:
```
    num_internal_networks = 3
    internal_network1_cidr = ""
    internal_network1_name = "internal_network1"
    internal_network1_subnetwork_name = "internal_subnetwork1"
    internal_network2_cidr = "10.0.4.0/24"
    internal_network2_name = ""
    internal_network2_subnetwork_name = ""
    internal_network3_cidr = "10.0.5.0/24"
    internal_network3_name = ""
    internal_network3_subnetwork_name = ""
```

## Inputs
| Name          | Description   | Type          | Allowed values | Default       | Required      |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| service_account_path | User service account path in JSON format - From the service account key page in the Cloud Console choose an existing account or create a new one. Next, download the JSON key file. Name it something you can remember, store it somewhere secure on your machine, and supply the path to the location is stored. (e.g. "service-accounts/service-account-name.json")  | string  | N/A | "" | yes |
| project  | Personal project id. The project indicates the default GCP project all of your resources will be created in.  | string  | N/A | "" | yes |
|  |  |  |  |  |
| prefix | (Optional) Resources name prefix. | string | N/A | "chkp-tf-ha" | no |
| license | Checkpoint license (BYOL or PAYG). | string | - BYOL <br/> - PAYG <br/> | "BYOL" | no |
| image_name | The High Availability (cluster) image name (e.g. check-point-r8040-gw-byol-cluster-123-456-v12345678). You can choose the desired cluster image value from [Github](https://github.com/CheckPointSW/CloudGuardIaaS/blob/master/gcp/deployment-packages/ha-byol/images.py). | string | N/A | N/A | yes |
|  |  |  |  |  |
| region  | GCP region  | string  | N/A | "us-central1" | no |
| zoneA  | Member A Zone. The zone determines what computing resources are available and where your data is stored and used.  | string  | N/A | "us-central1-a" | no |
| zoneB  | Member B Zone.  | string  | N/A | "us-central1-a" | no |
| machine_type | Machine types determine the specifications of your machines, such as the amount of memory, virtual cores, and persistent disk limits an instance will have. | string | N/A | "n1-standard-4" | no |
| disk_type | Storage space is much less expensive for a standard Persistent Disk. An SSD Persistent Disk is better for random IOPS or streaming throughput with low latency. | string | - SSD Persistent Disk <br/>  - Standard Persistent Disk | "SSD Persistent Disk" | no |
| disk_size | Disk size in GB - Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space. | number | number between 100 and 4096 | 100 | no |
| enable_monitoring | Enable Stackdriver monitoring | bool | true/false | false | no |
|  |  |  |  |  |
| management_network  | Security Management Server address - The public address of the Security Management Server, in CIDR notation. VPN peers addresses cannot be in this CIDR block, so this value cannot be the zero-address.  | string  | N/A | N/A | yes |
| sic_key  | The Secure Internal Communication one time secret used to set up trust between the cluster object and the management server. At least 8 alpha numeric characters. If SIC is not provided and needed, a key will be automatically generated  | string  | N/A | N/A | yes |
| generate_password  | Automatically generate an administrator password.  | bool | true/false | false | no |
| allow_upload_download | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point | bool | true/false | true | no |
| admin_shell | Change the admin shell to enable advanced command line configuration. | string | - /etc/cli.sh <br/> - /bin/bash <br/> - /bin/csh <br/> - /bin/tcsh | "/etc/cli.sh" | no |
| cluster_network_cidr  | Cluster external subnet CIDR. If the variable's value is not empty double quotes, a new network will be created. The Cluster public IP will be translated to a private address assigned to the active member in this external network.  | string  | N/A | "10.0.0.0/24" | no |
| cluster_network_name  | Cluster external network ID in the chosen zone. The network determines what network traffic the instance can access.If you have specified a CIDR block at var.cluster_network_cidr, this network name will not be used.  | string  | N/A | "" | no |
| cluster_network_subnetwork_name  | Cluster subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.cluster_network_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network.  | string  | N/A | "" | no |
| cluster_ICMP_traffic | (Optional) Source IP ranges for ICMP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty list to unable ICMP traffic. | list(string) | N/A | [] | no |
| cluster_TCP_traffic | (Optional) Source IP ranges for TCP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty list to unable TCP traffic. | list(string) | N/A | [] | no |
| cluster_UDP_traffic | (Optional) Source IP ranges for UDP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty list to unable UDP traffic. | list(string) | N/A | [] | no |
| cluster_SCTP_traffic | (Optional) Source IP ranges for SCTP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty list to unable SCTP traffic. | list(string) | N/A | [] | no |
| cluster_ESP_traffic | (Optional) Source IP ranges for ESP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. Please leave empty list to unable ESP traffic. | list(string) | N/A | [] | no |
| mgmt_network_cidr  | Management external subnet CIDR. If the variable's value is not empty double quotes, a new network will be created. The public IP used to manage each member will be translated to a private address in this external network.  | string  | N/A | "10.0.1.0/24" | no |
| mgmt_network_name  | Management network ID in the chosen zone. The network determines what network traffic the instance can access. If you have specified a CIDR block at var.mgmt_network_cidr, this network name will not be used.  | string  | N/A | "" | no |
| mgmt_network_subnetwork_name  | Management subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.mgmt_network_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network.  | string  | N/A | "" | no |
| mgmt_ICMP_traffic | (Optional) Source IP ranges for ICMP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty list to unable ICMP traffic. | list(string) | N/A | [] | no |
| mgmt_TCP_traffic | (Optional) Source IP ranges for TCP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty list to unable TCP traffic. | list(string) | N/A | [] | no |
| mgmt_UDP_traffic | (Optional) Source IP ranges for UDP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty list to unable SCTP traffic. | list(string) | N/A | [] | no |
| mgmt_SCTP_traffic | (Optional) Source IP ranges for SCTP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty list to unable TCP traffic. | list(string) | N/A | [] | no |
| mgmt_ESP_traffic | (Optional) Source IP ranges for ESP traffic - Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009. Please leave empty list to unable ESP traffic. | list(string) | N/A | [] | no |
| num_internal_networks | A number in the range 1 - 6 of internal network interfaces. | number | 1 - 6 | 1 | no |
| internal_network1_cidr  | 1st internal subnet CIDR. If the variable's value is not empty double quotes, a new subnet will be created. Assigns the cluster members an IPv4 address in this internal network.  | string  | N/A | "10.0.2.0/24" | no |
| internal_network1_name  | 1st internal network ID in the chosen zone. The network determines what network traffic the instance can access. If you have specified a CIDR block at var.internal_network1_cidr, this network name will not be used.  | string  | N/A | "" | no |
| internal_network1_subnetwork_name  | 1st internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.internal_network1_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network.  | string  | N/A | "" | no |



## Outputs
| Name  | Description |
| ------------- | ------------- |
| cluster_new_created_network  | If a new cluster network creation is selected - the cluster network name, otherwise, an empty list. |
| cluster_new_created_subnet  | If a new cluster network creation is selected - the cluster subnetwork name, otherwise, an empty list.  |
| mgmt_new_created_network  | If a new management network creation is selected - the management network name, otherwise, an empty list. |
| mgmt_new_created_subnet  | If a new management network creation is selected - the management subnetwork name, otherwise, an empty list. |
| int_network1_new_created_network  | If a new internal network 1 creation is selected - the internal network 1 network name, otherwise, an empty list.  |
| int_network1_new_created_subnet  | If a new internal network 1 creation is selected - the internal network 1 subnetwork name, otherwise, an empty list.  |
| cluster_ICMP_firewall_rule  | If enable - the cluster ICMP firewall rules name, otherwise, an empty list.  |
| cluster_TCP_firewall_rule  | If enable - the cluster TCP firewall rules name, otherwise, an empty list.  |
| cluster_UDP_firewall_rule  | If enable - the cluster UDP firewall rules name, otherwise, an empty list.  |
| cluster_SCTP_firewall_rule  | If enable - the cluster SCTP firewall rules name, otherwise, an empty list.  |
| cluster_ESP_firewall_rule  | If enable - the cluster ESP firewall rules name, otherwise, an empty list.  |
| mgmt_ICMP_firewall_rule  | If enable - the mgmt ICMP firewall rules name, otherwise, an empty list.  |
| mgmt_TCP_firewall_rule  | If enable - the mgmt TCP firewall rules name, otherwise, an empty list.  |
| mgmt_UDP_firewall_rule  | If enable - the mgmt UDP firewall rules name, otherwise, an empty list.  |
| mgmt_SCTP_firewall_rule  | If enable - the mgmt SCTP firewall rules name, otherwise, an empty list. |
| mgmt_ESP_firewall_rule  | If enable - the mgmt ESP firewall rules name, otherwise, an empty list. |
| cluster_ip_external_address  | Primary public IP address.  |
| admin_password  | If enable generate_password - the administrator password, otherwise, an empty list. |
| sic_key  | The Secure Internal Communication one time secret used to set up trust between the cluster object and the management server. |
| member_a_name  | Member A name. |
| member_a_external_ip  | Member A external ip. |
| member_a_zone  | Member A Zone. |
| member_b_name  | Member B name. |
| member_b_external_ip  | Member B external ip. |
| member_b_zone  | Member B Zone. |

## Revision History
In order to check the template version refer to the [sk116585](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk116585)

| Template Version | Description   |
| ---------------- | ------------- |
| 20201208 | First release of Check Point Check Point CloudGuard IaaS High Availability Terraform solution on GCP. |
| | | |
|  | Addition of "template_type" parameter to "cloud-version" files. |
| | | |

## Authors


## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details
