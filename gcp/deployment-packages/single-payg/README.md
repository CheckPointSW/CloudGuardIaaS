# GCP Deployment Manager package for Management, Gateway and Standalone PAYG solutions
This directory contains CloudGuard IaaS deployment package for Management, Gateway and Standalone PAYG solution published in the [GCP Marketplace](https://console.cloud.google.com/marketplace/details/checkpoint-public/check-point-cloudguard-payg).

# How to deploy the package manually
To deploy the Deployment Manager's package manually, without using the GCP Marketplace, follow these instructions:
1. Clone or download the files in this directory
2. Fill variables in the config.yaml(see below for variables descriptions).
3. Log into [Google Cloud Platform Console](https://console.cloud.google.com)
4. [Activate Cloud Shell](https://cloud.google.com/shell/docs/using-cloud-shell)
5. Set your Cloud Platform project in the Cloud Shell session use:
        
        gcloud config set project [PROJECT_ID]
6. Upload the content of the CloudGuardIaaS/gcp/deployment-packages/single-payg/ directory to the [cloud shell](https://cloud.google.com/shell/docs/uploading-and-downloading-files) 
7. Launch deployment by running:
        
         gcloud deployment-manager deployments create [DEPLOYMENT_NAME] --config config.yaml
8. Make sure the deployment finished successfully. <br>Example of successful deployment output:
        
        The fingerprint of the deployment is NEBnvNbqOItDoLZrhYNo5Q==
        Waiting for create [operation-1585065238276-5a19bc2792a32-becd058d-67862f39]...done.
        Create operation operation-1585065238276-5a19bc2792a32-becd058d-67862f39 completed successfully.
        NAME                        TYPE                          STATE      ERRORS  INTENT
        gateway-config              runtimeconfig.v1beta1.config  COMPLETED  []
        gateway-software            runtimeconfig.v1beta1.waiter  COMPLETED  []
        gateway-vm                  compute.v1.instance           COMPLETED  []
        gateway-vm-address          compute.v1.address            COMPLETED  []
        OUTPUTS     VALUE
        Deployment  gateway
        Instance    gateway-single-vm
        
## config.yaml variables
| Name          | Description   | Type          | Allowed values |
| ------------- | ------------- | ------------- | -------------  |
| **zone** | The zone determines what computing resources are available and where your data is stored and used | string | List of allowed [Regions and Zones](https://cloud.google.com/compute/docs/regions-zones?_ga=2.31926582.-962483654.1585043745) |
|  |  |  |  |  |
| **machineType** | Machine types determine the specifications of your machines, such as the amount of memory, virtual cores, and persistent disk limits an instance will have | string | [Learn more about Machine Types](https://cloud.google.com/compute/docs/machine-types?hl=en_US&_ga=2.267871494.-962483654.1585043745) |
|  |  |  |  |  |
| **network** | The network determines what network traffic the instance can access | string | Available network in the chosen zone  |
|  |  |  |  |  |
| **Subnetwork** | Assigns the instance an IPv4 address from the subnetwork’s range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network. | string | Available subnetwork in the chosen network  |
|  |  |  |  |  |
| **network_enableTcp** | Allow TCP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **network_tcpSourceRanges** | Allow TCP traffic from the Internet | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009 [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **network_enableGwNetwork** | This is relevant for **Management** only. The network in which managed gateways reside | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **network_gwNetworkSourceRanges** | Allow TCP traffic from the Internet | string | Enter a valid IPv4 network CIDR (e.g. 0.0.0.0/0) |
|  |  |  |  |  |
| **network_enableIcmp** | Allow ICMP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **network_icmpSourceRanges** | Source IP ranges for ICMP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **network_enableUdp** | Allow UDP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **network_udpSourceRanges** | Source IP ranges for UDP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only - all ports are allowed. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **network_enableSctp** | Allow SCTP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **network_sctpSourceRanges** | Source IP ranges for SCTP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only - all ports are allowed. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **network_enableEsp** | Allow ESP traffic from the Internet | boolean | true; <br/>false; |
|  |  |  |  |  |
| **network_espSourceRanges** | Source IP ranges for ESP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **externalIP** | External IP address type | string | Static;<br/>Ephemeral;<br/>None;<br/>An external IP address associated with this instance. Selecting "None" will result in the instance having no external internet access. [Learn more](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address?_ga=2.259654658.-962483654.1585043745) |
|  |  |  |  |  |
| **installationType** | Installation type and version | string | R80.30 Gateway only;<br/>R80.30 Management only;<br/>R80.30 Manual Configuration<br/>R80.40 Gateway only<br/>R80.40 Management only<br/>R80.40 Manual Configuration<br/>R80.40 Gateway and Management (Standalone) |
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
| **managementGUIClientNetwork** | Allowed GUI clients | string | A valid IPv4 network CIDR (e.g. 0.0.0.0/0) |
|  |  |  |  |  |
| **numAdditionalNICs** | Number of additional network interfaces | number | A number in the range 0 - 7.<br/>Multiple network interfaces deployment is described in [sk121637 - Deploy a CloudGuard for GCP with Multiple Network Interfaces](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk121637) |
|  |  |  |  |  |

## Example
    zone: "asia-east1-a"
    machineType: "n1-standard-4"
    network: "frontend-vpc"
    subnetwork: "frontend"
    network_enableTcp: true
    network_tcpSourceRanges: "0.0.0.0/0"
    network_enableGwNetwork: true
    network_gwNetworkSourceRanges: "0.0.0.0/0"					  							 
    network_enableIcmp: true
    network_icmpSourceRanges: "0.0.0.0/0"
    network_enableUdp: true
    network_udpSourceRanges: "0.0.0.0/0"
    network_enableSctp: false
    network_sctpSourceRanges: ""
    network_enableEsp: false
    network_espSourceRanges: ""
    externalIP: "Static"
    installationType: "R80.30 Gateway only"
    diskType: "pd-ssd"
    bootDiskSizeGb: 100
    generatePassword: false
    allowUploadDownload: true
    enableMonitoring: false
    shell: "/bin/bash"
    instanceSSHKey: "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
    sicKey: "xxxxxxxx"
    managementGUIClientNetwork: "0.0.0.0/0"
    numAdditionalNICs: 1
    additionalNetwork1: "backend-vpc1"
    additionalSubnetwork1: "backend1"
    externalIP1": "None"
    additionalNetwork2": "backend-vpc2"
    additionalSubnetwork2": "backend2"
    externalIP2": "None"




## Notes
See [sk147032](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk147032) for revision history