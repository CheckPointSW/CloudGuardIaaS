# Check Point single gateway and management Terraform module for GCP

Terraform module which deploys a single gateway and management of Check Point Security Gateways.

These types of Terraform resources are supported:
[Instance Template](https://www.terraform.io/docs/providers/google/r/compute_instance_template.html)
[Firewall](https://www.terraform.io/docs/providers/google/r/compute_firewall.html) - conditional creation
[Instance Group Manager](https://www.terraform.io/docs/providers/google/r/compute_region_instance_group_manager.html)
[Compute instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)

See Check Point's documentation for Single [here](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk114577)

Terraform is controlled via a very easy to use command-line interface (CLI). Terraform is only a single command-line application: terraform.

## Before you begin

1. Create a project in the [Google Cloud Console](https://console.cloud.google.com/) and set up billing on that project.
2. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) and read the Terraform getting started guide that follows. This guide will assume basic proficiency with Terraform - it is an introduction to the Google provider.

## Configuring the Provider

The main.tf file includes the following provider configuration block used to configure the credentials you use to authenticate with GCP, as well as a default project and location for your resources:

```
provider "google" {
  credentials = file(var.service_account_path)
  project     = var.project
}
...
```

1.  [Create a Service Account](https://cloud.google.com/docs/authentication/getting-started) (or use the existing one). Next, download the JSON key file. Name it something you can remember and store it somewhere secure on your machine. <br/>
2.  Select "Editor" Role or verify you have the following permissions:
    ```
     compute.addresses.create
     compute.addresses.delete
     compute.addresses.get
     compute.addresses.use
     compute.disks.create
     compute.firewalls.create
     compute.firewalls.delete
     compute.firewalls.get
     compute.firewalls.update
     compute.instances.create
     compute.instances.delete
     compute.instances.deleteAccessConfig
     compute.instances.get
     compute.instances.setLabels
     compute.instances.setMachineType
     compute.instances.setMetadata
     compute.instances.setServiceAccount
     compute.instances.setTags
     compute.instances.updateNetworkInterface
     compute.networks.create
     compute.networks.delete
     compute.networks.get
     compute.networks.updatePolicy
     compute.regionOperations.get
     compute.regions.list
     compute.subnetworks.create
     compute.subnetworks.delete
     compute.subnetworks.get
     compute.subnetworks.use
     compute.subnetworks.useExternalIp
     compute.zones.get
     iam.serviceAccounts.actAs
    ```
3.  `credentials` - Your service account key file is used to complete a two-legged OAuth 2.0 flow to obtain access tokens to authenticate with the GCP API as needed; Terraform will use it to reauthenticate automatically when tokens expire. <br/>
    The provider credentials can be provided either as static credentials or as [Environment Variables](https://www.terraform.io/docs/providers/google/guides/provider_reference.html#credentials-1). - Static credentials can be provided by adding the path to your service-account json file, project-id and region in /gcp/modules/single/terraform.tfvars file as follows:
    `      service_account_path = "service-accounts/service-account-file-name.json"
project = "project-id"` - In case the Environment Variables are used, perform modifications described below:<br/>
    a. The next lines in the main.tf file, in the provider google resource, need to be deleted or commented:
    ` provider "google" {
    // credentials = file(var.service_account_path)
    // project = var.project
            }
           ```
           b.In the terraform.tfvars file leave empty double quotes for credentials and project variables:
           ```
           service_account_path = ""
           project = ""
           ``` `

## Usage

- Fill all variables in the /gcp/single/terraform.tfvars file with proper values (see below for variables descriptions).
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

#### Variables are configured in single/terraform.tfvars file as follows:

```
# --- Google Provider ---
service_account_path = "service-accounts/service-account-file-name.json"
project = "project-id"

# --- Check Point---
image_name = "check-point-r8120-gw-byol-single-631-991001669-v20240923"
os_version = "R8120"
installation_type = "Gateway only"
license = "BYOL"
prefix = "chkp-single-tf-"
management_nic = "Ephemeral Public IP (eth0)"
admin_shell = "/etc/cli.sh"
admin_SSH_key = "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
maintenance_mode_password_hash = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
generate_password = false
allow_upload_download = true
sic_key = "xxxxxxxxx"
management_gui_client_network = "0.0.0.0/0"

#--- Quick connect to Smart-1 Cloud ---
smart_1_cloud_token = "xxxxxxxxxxxxxxxxxxxxxxxx"

# --- Networking ---
region = "us-central1"
zone = "us-central1-a"
network_name = ""
subnetwork_name = ""
network_cidr = "10.0.0.0/24"
TCP_traffic = ["0.0.0.0/0"]
ICMP_traffic  = []
UDP_traffic = []
SCTP_traffic = []
ESP_traffic = []
num_additional_networks = 1
external_ip = "static"
internal_network1_name = ""
internal_network1_subnetwork_name = ""
internal_network1_cidr = "10.0.1.0/24"

# --- Instance Configuration ---
machine_type = "n1-standard-4"
disk_type = "SSD Persistent Disk"
disk_size = 100
enable_monitoring = false

```

- To tear down your resources:
  ```
  terraform destroy
  ```

## Conditional creation

<br>1. For each network and subnet variable, you can choose whether to create a new network with a new subnet or to use an existing one.

- If you want to create a new network and subnet, please input a subnet CIDR block for the desired new network - In this case, the network name and subnetwork name will not be used:

```
    network_cidr = "10.0.1.0/24"
    network_name = "not-use"
    network_subnetwork_name = "not-use"
```

- Otherwise, if you want to use existing network and subnet, please leave empty double quotes in the CIDR variable for the desired network:

```
    network_cidr = ""
    network_name = "network_name"
    network_subnetwork_name = "subnetwork_name"
```

<br>2. To create Firewall and allow traffic for ICMP, TCP, UDP, SCTP or/and ESP - enter list of Source IP ranges.

```
ICMP_traffic = ["123.123.0.0/24", "234.234.0.0/24"]
TCP_traffic = ["0.0.0.0/0"]
UDP_traffic = ["0.0.0.0/0"]
SCTP_traffic = ["0.0.0.0/0"]
ESP_traffic = ["0.0.0.0/0"]
```

Please leave empty list for a protocol if you want to disable traffic for it.

## Inputs

| Name                              | Description                                                                                                                                                                                                                                                                                                                                                           | Type         | Allowed values                                                                                                                                                                                                                                                                                                                                         | Default                     | Required |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------- | -------- |
| service_account_path              | User service account path in JSON format - From the service account key page in the Cloud Console choose an existing account or create a new one. Next, download the JSON key file. Name it something you can remember, store it somewhere secure on your machine, and supply the path to the location is stored. (e.g. "service-accounts/service-account-name.json") | string       | N/A                                                                                                                                                                                                                                                                                                                                                    | ""                          | yes      |
| project                           | Personal project ID. The project indicates the default GCP project all of your resources will be created in. The project ID must be 6-30 characters long, start with a letter, and can only include lowercase letters, numbers, hyphenst and cannot end with a hyphen.                                                                                                                                                                                                                                                          | string       | N/A                                                                                                                                                                                                                                                                                                                                                    | ""                          | yes      |
| region                            | GCP region                                                                                                                                                                                                                                                                                                                                                            | string       | N/A                                                                                                                                                                                                                                                                                                                                                    | N/A                         | yes      |
| zone                              | The zone determines what computing resources are available and where your data is stored and used                                                                                                                                                                                                                                                                     | string       | List of allowed [Regions and Zones](https://cloud.google.com/compute/docs/regions-zones?_ga=2.31926582.-962483654.1585043745)                                                                                                                                                                                                                          | us-central1-a               | yes      |
| image_name                        | The single gateway or management image name (e.g. check-point-r8120-gw-byol-single-631-991001669-v20240923 for gateway or check-point-r8120-byol-634-991001641-v20240807 for management). You can choose the desired gateway image value from [Github](https://github.com/CheckPointSW/CloudGuardIaaS/blob/master/gcp/deployment-packages/single-byol/images.py).     | string       | N/A                                                                                                                                                                                                                                                                                                                                                    | N/A                         | yes      |
| os_version                        | GAIA OS Version                                                                                                                                                                                                                                                                                                                                                       | string       | R81;<br/> R8110;<br/> R8120;<br/> R82;                                                                                                                                                                                                                                                                                                                            | R8120                       | yes      |
| installation_type                  | Installation type                                                                                                                                                                                                                                                                                                                                         | string       | Gateway only;<br/> Management only;<br/> Manual Configuration<br/>Gateway and Management (Standalone)                                                                                                                                                                                                                                                  | Gateway only                | yes      |
| license                           | Checkpoint license (BYOL or PAYG).                                                                                                                                                                                                                                                                                                                                    | string       | BYOL; <br/>PAYG;                                                                                                                                                                                                                                                                                                                                       | BYOL                        | yes      |
| prefix                            | (Optional) Resources name prefix                                                                                                                                                                                                                                                                                                                                      | string       | N\A                                                                                                                                                                                                                                                                                                                                                    | chkp-single-tf-             | no       |
| machine_type                       | Machine types determine the specifications of your machines, such as the amount of memory, virtual cores, and persistent disk limits an instance will have                                                                                                                                                                                                            | string       | [Learn more about Machine Types](https://cloud.google.com/compute/docs/machine-types?hl=en_US&_ga=2.267871494.-962483654.1585043745)                                                                                                                                                                                                                   | n1-standard-4               | no       |
| network_name                      | network ID in the chosen zone. The network determines what network traffic the instance can access                                                                                                                                                                                                                                                                    | string       | N/A                                                                                                                                                                                                                                                                                                                                                    | N/A                         | no       |
| subnetwork_name                   | subNetwork ID in the chosen zone. The subNetwork determines what network traffic the instance can access                                                                                                                                                                                                                                                              | string       | N/A                                                                                                                                                                                                                                                                                                                                                    | N/A                         | no       |
| network_cidr                      | The range of internal addresses that are owned by this network, only IPv4 is supported (e.g. "10.0.0.0/8" or "192.168.0.0/16").                                                                                                                                                                                                                                       | string       | N/A                                                                                                                                                                                                                                                                                                                                                    | N/A                         | no       |
| TCP_traffic           | Allow TCP traffic from the Internet                                                                                                                                                                                                                                                                                                                                   | list(string) | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009 [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls)                          | N/A                         | no       |  |
| ICMP_traffic           | Source IP ranges for ICMP traffic                                                                                                                                                                                                                                                                                                                                     | list(string) | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls)                                                                                                                      | N/A                         | no       |
| UDP_traffic            | Source IP ranges for UDP traffic                                                                                                                                                                                                                                                                                                                                      | list(string) | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only - all ports are allowed. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls)                                                                                              | N/A                         | no       |
| SCTP_traffic           | Source IP ranges for SCTP traffic                                                                                                                                                                                                                                                                                                                                     | list(string) | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only - all ports are allowed. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls)                                                                                              | N/A                         | no       |
| ESP_traffic            | Source IP ranges for ESP traffic                                                                                                                                                                                                                                                                                                                                      | list(string) | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls)                                                                                                                      | N/A                         | no       |
| disk_type                          | Disk type                                                                                                                                                                                                                                                                                                                                                             | string       | SSD Persistent Disk;<br/>standard-Persistent Disk;<br/>Storage space is much less expensive for a standard persistent disk. An SSD persistent disk is better for random IOPS or streaming throughput with low latency. [Learn more](https://cloud.google.com/compute/docs/disks/?hl=en_US&_ga=2.66020774.-962483654.1585043745#overview_of_disk_types) | SSD Persistent Disk         | no       |
| disk_size                    | Disk size in GB                                                                                                                                                                                                                                                                                                                                                       | number       | Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space. [Learn more](https://cloud.google.com/compute/docs/disks/?hl=en_US&_ga=2.232680471.-962483654.1585043745#pdperformance)                                                                                | 100                         | no       |
| generate_password                  | Automatically generate an administrator password                                                                                                                                                                                                                                                                                                                      | boolean      | true; <br/>false;                                                                                                                                                                                                                                                                                                                                      | false                       | no       |
| allow_upload_download               | Allow download from/upload to Check Point                                                                                                                                                                                                                                                                                                                             | boolean      | true; <br/>false;                                                                                                                                                                                                                                                                                                                                      | true                       | no       |
| enable_monitoring                  | Enable Stackdriver monitoring                                                                                                                                                                                                                                                                                                                                         | boolean      | true; <br/>false;                                                                                                                                                                                                                                                                                                                                      | false                       | no       |
| admin_shell                       | Change the admin shell to enable advanced command line configuration.                                                                                                                                                                                                                                                                                                 | string       | /etc/cli.sh;<br/>/bin/bash;<br/>/bin/csh;<br/>/bin/tcsh;<br/>                                                                                                                                                                                                                                                                                          | /etc/cli.sh                 | no       |
| admin_SSH_key                     | Public SSH key for the user 'admin' - The SSH public key for SSH authentication to the instances. Leave this field blank to use all project-wide pre-configured SSH keys.                                                                                                                                                                                             | string       | A valid public ssh key                                                                                                                                                                                                                                                                                                                                 | ""                          | no       |
| maintenance_mode_password_hash    | Maintenance mode password hash, relevant only for R81.20 and higher versions, to generate a password hash use the command 'grub2-mkpasswd-pbkdf2' on Linux and paste it here.                                                                                                                                                                                         | string       |                                                                                                                                                                                                                                                                                                                                                        | ""                          | no       |
| sic_key                            | The Secure Internal Communication one time secret used to set up trust between the single gateway object and the management server                                                                                                                                                                                                                                    | string       | At least 8 alpha numeric characters.<br/>If SIC is not provided and needed, a key will be automatically generated                                                                                                                                                                                                                                      | ""                          | no       |
| management_gui_client_network        | Allowed GUI clients                                                                                                                                                                                                                                                                                                                                                   | string       | A valid IPv4 network CIDR (e.g. 0.0.0.0/0)                                                                                                                                                                                                                                                                                                             | 0.0.0.0/0                   | no       |
| smart_1_cloud_token               | Smart-1 Cloud token to connect this gateway to Check Point's Security Management as a Service. <br/><br/> Follow these instructions to quickly connect this member to Smart-1 Cloud - [SK180501](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk180501)                                                  | string       | A valid token copied from the Connect Gateway screen in Smart-1 Cloud portal.                                                                                                                                                                                                                                                                          |
| num_additional_networks             | Number of additional network interfaces                                                                                                                                                                                                                                                                                                                               | number       | A number in the range 1 - 8.<br/>Multiple network interfaces deployment is described in [sk121637 - Deploy a CloudGuard for GCP with Multiple Network Interfaces](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk121637)                                                                  | 0                           | no       |
| external_ip                        | External IP address type                                                                                                                                                                                                                                                                                                                                              | string       | static;<br/>ephemeral;<br/>An external IP address associated with this instance. Selecting "none" will result in the instance having no external internet access. [Learn more](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address?_ga=2.259654658.-962483654.1585043745)                                            | static                      | no       |
| internal_network1_name            | 1st internal network ID in the chosen zone. The network determines what network traffic the instance can access. If you have specified a CIDR block at var.internal_network1_cidr, this network name will not be used.                                                                                                                                                | string       | Available network in the chosen zone                                                                                                                                                                                                                                                                                                                   | N/A                         | no       |
| internal_network1_subnetwork_name | 1st internal subnet ID in the chosen network. Assigns the instance an IPv4 address from the subnetwork’s range. If you have specified a CIDR block at var.internal_network1_cidr, this subnetwork will not be used. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network.           | string       | Available subNetwork in the chosen zone                                                                                                                                                                                                                                                                                                                | N/A                         | no       |
| internal_network1_cidr            | The range of internal addresses that are owned by this subnetwork, only IPv4 is supported (e.g. "10.0.0.0/8" or "192.168.0.0/16").                                                                                                                                                                                                                                    | string       | N/A                                                                                                                                                                                                                                                                                                                                                    | N/A                         | no       |
| management_nic                    | Management Interface - Security Gateways in GCP can be managed by an ephemeral public IP or using the private IP of the internal interface (eth1).                                                                                                                                                                                                                    | string       | Ephemeral Public IP (eth0) <br/> - Private IP (eth1)                                                                                                                                                                                                                                                                                                   | Ephemeral Public IP (eth0) | no       |

## Outputs

| Name                     | Description                                                                  |
| ------------------------ | ---------------------------------------------------------------------------- |
| network                  | If network_cidr has been set - it will create new network                    |
| subnet                   | If network_cider has been set - it will create new subnet in the new network |
| SIC_key                  | Secure Internal Communication (SIC) initiation key.                          |
| ICMP_firewall_rules_name | If enable - the ICMP firewall rules name, otherwise, an empty list.          |
| TCP_firewall_rules_name  | If enable - the TCP firewall rules name, otherwise, an empty list.           |
| UDP_firewall_rules_name  | If enable - the UDP firewall rules name, otherwise, an empty list.           |
| SCTP_firewall_rules_name | If enable - the SCTP firewall rules name, otherwise, an empty list.          |
| ESP_firewall_rules_name  | If enable - the ESP firewall rules name, otherwise, an empty list.           |

## Revision History

In order to check the template version refer to the [sk116585](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk116585)

| Template Version | Description                                                       |
| ---------------- | ------------------------------------------------------------------|
| 20240909         | Merged single-into-new-vpc and single-into-existing-vpc to single template|
|                  |                                                                   |

## Authors

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details
