# GCP Deployment Manager package for Check Point High Availability BYOL solution
This directory contains CloudGuard IaaS deployment package for Check Point High Availability (BYOL) solution published in the [GCP Marketplace](https://console.cloud.google.com/marketplace/details/checkpoint-public/check-point-ha--byol).

# How to deploy the package manually
To deploy the Deployment Manager's package manually, without using the GCP Marketplace, follow these instructions:
1. Clone or download the files in this directory
2. Fill variables in the config.yaml(see below for variables descriptions).
3. Log into [Google Cloud Platform Console](https://console.cloud.google.com)
4. [Activate Cloud Shell](https://cloud.google.com/shell/docs/using-cloud-shell)
5. Set your Cloud Platform project in the Cloud Shell session use:
        
        gcloud config set project [PROJECT_ID]
6. Upload the content of the CloudGuardIaaS/gcp/deployment-packages/ha-byol/ directory to the [cloud shell](https://cloud.google.com/shell/docs/uploading-and-downloading-files) 
7. Launch deployment by running:
        
         gcloud deployment-manager deployments create [DEPLOYMENT_NAME] --config config.yaml
8. Make sure the deployment finished successfully. <br>Example of successful deployment output:
        
        The fingerprint of the deployment is CgwkIUxcTnI5_eZY1g9SFw==
        Waiting for create [operation-1585150261645-5a1af8e42d0ba-6b3d4618-5856e790]...done.
        Create operation operation-1585150261645-5a1af8e42d0ba-6b3d4618-5856e790 completed successfully.
        NAME                                        TYPE                          STATE      ERRORS  INTENT
        cluster2-cluster-network-icmp               compute.v1.firewall           COMPLETED  []
        cluster2-cluster-network-tcp                compute.v1.firewall           COMPLETED  []
        cluster2-config                             runtimeconfig.v1beta1.config  COMPLETED  []
        cluster2-member-a                           compute.v1.instance           COMPLETED  []
        cluster2-member-a-address                   compute.v1.address            COMPLETED  []
        cluster2-member-b                           compute.v1.instance           COMPLETED  []
        cluster2-member-b-address                   compute.v1.address            COMPLETED  []
        cluster2-mgmt-network-esp                   compute.v1.firewall           COMPLETED  []
        cluster2-mgmt-network-sctp                  compute.v1.firewall           COMPLETED  []
        cluster2-primary-cluster-address            compute.v1.address            COMPLETED  []
        cluster2-secondary-cluster-address          compute.v1.address            COMPLETED  []
        cluster2-software                           runtimeconfig.v1beta1.waiter  COMPLETED  []

## config.yaml variables
| Name          | Description   | Type          | Allowed values |
| ------------- | ------------- | ------------- | -------------  |
| **ha_version** | High Availability Version | string | R80.30 Cluster;<br/>R80.40 Cluster; |
|  |  |  |  |  |
| **zoneA** | Member A Zone. The zone determines what computing resources are available and where your data is stored and used | string | List of allowed [Regions and Zones](https://cloud.google.com/compute/docs/regions-zones?_ga=2.31926582.-962483654.1585043745) |
|  |  |  |  |  |
| **zoneB** | Member B Zone | string | Must be in the same region as member A zone |
|  |  |  |  |  |
| **machineType** | Machine types determine the specifications of your machines, such as the amount of memory, virtual cores, and persistent disk limits an instance will have | string | [Learn more about Machine Types](https://cloud.google.com/compute/docs/machine-types?hl=en_US&_ga=2.267871494.-962483654.1585043745) |
|  |  |  |  |  |
| **managementNetwork** | Security Management Server address | string | The public address of the Security Management Server, in CIDR notation. VPN peers addresses cannot be in this CIDR block, so this value cannot be the zero-address |
|  |  |  |  |  |
| **cluster-network-cidr** | Cluster external subnet CIDR.<br/>If the variable's value is not empty double quotes, a new network will be created.<br/> The Cluster public IP will be translated to a private address assigned to the active member in this external network.  | string | Specify an RFC 1918 CIDR block that does not overlap with your other networks to create a new network or select an existing one below  |
|  |  |  |  |  |
| **cluster-network-name** | Cluster external network ID. The network determines what network traffic the instance can access | string | Available network in the chosen zone  |
|  |  |  |  |  |
| **cluster-network-subnetwork-name** | Cluster subnet ID. Assigns the instance an IPv4 address from the subnetwork’s range.<br/>If you have specified a CIDR block above, this subnetwork will not be used.<br/>. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network. | string | Available subnetwork in the chosen network  |
|  |  |  |  |  |
| **cluster-network_enableTcp** | Allow TCP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **cluster-network_tcpSourceRanges** | Allow TCP traffic from the Internet | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009 [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **cluster-network_enableIcmp** | Allow ICMP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **cluster-network_icmpSourceRanges** | Source IP ranges for ICMP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **cluster-network_enableUdp** | Allow UDP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **cluster-network_udpSourceRanges** | Source IP ranges for UDP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only - all ports are allowed. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **cluster-network_enableSctp** | Allow SCTP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **cluster-network_sctpSourceRanges** | Source IP ranges for SCTP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only - all ports are allowed. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **cluster-network_enableEsp** | Allow ESP traffic from the Internet | boolean | true; <br/>false; |
|  |  |  |  |  |
| **cluster-network_espSourceRanges** | Source IP ranges for ESP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **mgmt-network-cidr** | Management external subnet CIDR.<br/>If the variable's value is not empty double quotes, a new network will be created.<br/> The public IP used to manage each member will be translated to a private address in this external network | string | Specify an RFC 1918 CIDR block that does not overlap with your other networks to create a new network or select an existing one below  |
|  |  |  |  |  |
| **mgmt-network-name** | Management network ID. The network determines what network traffic the instance can access | string | Available network in the chosen zone  |
|  |  |  |  |  |
| **mgmt-network-subnetwork-name** | Management subnet ID. Assigns the instance an IPv4 address from the subnetwork’s range.<br/>If you have specified a CIDR block above, this subnetwork will not be used.<br/>. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network. | string | Available subnetwork in the chosen network  |
|  |  |  |  |  |
| **mgmt-network_enableTcp** | Allow TCP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **mgmt-network_tcpSourceRanges** | Allow TCP traffic from the Internet | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009 [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **mgmt-network_enableIcmp** | Allow ICMP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **mgmt-network_icmpSourceRanges** | Source IP ranges for ICMP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **mgmt-network_enableUdp** | Allow UDP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **mgmt-network_udpSourceRanges** | Source IP ranges for UDP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only - all ports are allowed. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **mgmt-network_enableSctp** | Allow SCTP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **mgmt-network_sctpSourceRanges** | Source IP ranges for SCTP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only - all ports are allowed. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **mgmt-network_enableEsp** | Allow ESP traffic from the Internet | boolean | true; <br/>false; |
|  |  |  |  |  |
| **mgmt-network_espSourceRanges** | Source IP ranges for ESP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **diskType** | Disk type | string | pd-ssd;<br/>pd-standard;<br/>Storage space is much less expensive for a standard persistent disk. An SSD persistent disk is better for random IOPS or streaming throughput with low latency. [Learn more](https://cloud.google.com/compute/docs/disks/?hl=en_US&_ga=2.66020774.-962483654.1585043745#overview_of_disk_types)|
|  |  |  |  |  |
| **bootDiskSizeGb** | Disk size in GB | number | Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space. [Learn more](https://cloud.google.com/compute/docs/disks/?hl=en_US&_ga=2.232680471.-962483654.1585043745#pdperformance)|
|  |  |  |  |  |
| **generatePassword** | Automatically generate an administrator password | boolean | true; <br/>false; |
|  |  |  |  |  |
| **allowUploadDownload** | Allow download from/upload to Check Point  | boolean | true; <br/>false; |
|  |  |  |  |  |
| **enableMonitoring** | Enable Stackdriver monitoring | boolean | true; <br/>false; |
|  |  |  |  |  |
| **shell** | Admin shell | string | /etc/cli.sh;<br/>/bin/bash;<br/>/bin/csh;<br/>/bin/tcsh;<br/> |
|  |  |  |  |  |
| **instanceSSHKey** | Public SSH key for the user 'admin' | string | A valid public ssh key |
|  |  |  |  |  |
| **sicKey** | The Secure Internal Communication one time secret used to set up trust between the cluster object and the management server | string | At least 8 alpha numeric characters.<br/>If SIC is not provided and needed, a key will be automatically generated |
|  |  |  |  |  |
| **numAdditionalNICs** | Number of additional network interfaces | number | A number in the range 0 - 6.<br/>Multiple network interfaces deployment is described in [sk121637 - Deploy a CloudGuard for GCP with Multiple Network Interfaces](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk121637) |
|  |  |  |  |  |
| **internal-network1-cidr** | 1st internal subnet CIDR.<br/>If the variable's value is not empty double quotes, a new subnet will be created.<br/> Assigns the cluster members an IPv4 address in this internal network | string | Specify an RFC 1918 CIDR block that does not overlap with your other networks to create a new network or select an existing one below  |
|  |  |  |  |  |
| **internal-network1-name** | 1st internal network ID. The network determines what network traffic the instance can access | string | Available network in the chosen zone  |
|  |  |  |  |  |
| **internal-network1-subnetwork-name** | 1st internal subnet ID. Assigns the instance an IPv4 address from the subnetwork’s range.<br/>If you have specified a CIDR block above, this subnetwork will not be used.<br/> Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network. | string | Available subnetwork in the chosen network  |
|  |  |  |  |  |
## Example
    ha_version: "R80.30 Cluster"
    zoneA: "asia-east1-a"
    zoneB: "asia-east1-a"
    machineType: "n1-standard-4"
    diskType: "pd-ssd"
    bootDiskSizeGb: 100
    instanceSSHKey: "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
    enableMonitoring: false
    managementNetwork: "209.87.209.100/32"
    sicKey: "aaaaaaaa"
    generatePassword: false
    allowUploadDownload: false
    shell: "/bin/bash"
    cluster-network-cidr: ""
    cluster-network-name: "romanka-vpc"
    cluster-network-subnetwork-name: "frontend"
    cluster-network_enableIcmp: true
    cluster-network_icmpSourceRanges: "0.0.0.0/0"
    cluster-network_enableTcp: true
    cluster-network_tcpSourceRanges: "0.0.0.0/0"
    cluster-network_enableUdp: false
    cluster-network_udpSourceRanges: ""
    cluster-network_enableSctp: false
    cluster-network_sctpSourceRanges: ""
    cluster-network_enableEsp: false
    cluster-network_espSourceRanges: ""
    mgmt-network-cidr: "10.0.2.0/24"
    mgmt-network-name: "vpc-internal"
    mgmt-network-subnetwork-name: ""
    mgmt-network_enableIcmp: false
    mgmt-network_icmpSourceRanges: ""
    mgmt-network_enableTcp: false
    mgmt-network_tcpSourceRanges: ""
    mgmt-network_enableUdp: true
    mgmt-network_udpSourceRanges: "0.0.0.0/0"
    mgmt-network_enableSctp: true
    mgmt-network_sctpSourceRanges: "0.0.0.0/0"
    mgmt-network_enableEsp: true
    mgmt-network_espSourceRanges: "0.0.0.0/0"
    numInternalNetworks: 1
    internal-network1-cidr: ""
    internal-network1-name: "vpc-internal2"
    internal-network1-subnetwork-name: "vpc-internal2"

## Notes
See [sk147032](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk147032) for revision history