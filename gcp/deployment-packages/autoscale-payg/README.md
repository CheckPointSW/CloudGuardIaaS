# GCP Deployment Manager package for Check Point Autoscaling PAYG solution
This directory contains CloudGuard IaaS deployment package for Check Point Autoscaling (PAYG) solution published in the [GCP Marketplace](https://console.cloud.google.com/marketplace/details/checkpoint-public/check-point-autoscaling-ngtp).

# How to deploy the package manually
To deploy the Deployment Manager's package manually, without using the GCP Marketplace, follow these instructions:
1. Clone or download the files in this directory
2. Fill variables in the config.yaml(see below for variables descriptions).
3. Log into [Google Cloud Platform Console](https://console.cloud.google.com)
4. [Activate Cloud Shell](https://cloud.google.com/shell/docs/using-cloud-shell)
5. Set your Cloud Platform project in the Cloud Shell session use:
        
        gcloud config set project [PROJECT_ID]
6. Upload the content of the CloudGuardIaaS/gcp/deployment-packages/autoscale-payg/ directory to the [cloud shell](https://cloud.google.com/shell/docs/uploading-and-downloading-files) 
7. Launch deployment by running:
        
         gcloud deployment-manager deployments create [DEPLOYMENT_NAME] --config config.yaml
8. Make sure the deployment finished successfully. <br>Example of successful deployment output:
        
        The fingerprint of the deployment is h8R2exQYuc4bzlO14boUhg==
        Waiting for create [operation-1585217870871-5a1bf4c15b9ea-f8d824d5-1089cc78]...done.
        Create operation operation-1585217870871-5a1bf4c15b9ea-f8d824d5-1089cc78 completed successfully.
        NAME                           TYPE                                   STATE      ERRORS  INTENT
        mig-as                         compute.v1.regionAutoscaler            COMPLETED  []
        mig-igm                        compute.v1.regionInstanceGroupManager  COMPLETED  []
        mig-vpc-icmp                   compute.v1.firewall                    COMPLETED  []
        mig-vpc-udp                    compute.v1.firewall                    COMPLETED  []
        mig-tmplt                      compute.v1.instanceTemplate            COMPLETED  []
        OUTPUTS                 VALUE
        Deployment              autoscale
        Managed instance group  https://www.googleapis.com/compute/v1/projects/checkpoint/regions/asia-east1/instanceGroups/autoscale-igm
        Minimum instances       2
        Maximum instances       10
        Target CPU usage        60%

## config.yaml variables
| Name          | Description   | Type          | Allowed values |
| ------------- | ------------- | ------------- | -------------  |
| **autoscalingVersion** | Autoscaling Version | string | R80.40 Autoscaling;<br/>R81.00 Autoscaling;<br/>R81.10 Autoscaling;<br/>R81.20 Autoscaling;|
|  |  |  |  |  |
| **managementName** | Security Management Server name | string | The name of the Security Management Server as appears in autoprovisioning configuration |
|  |  |  |  |  |
| **AutoProvTemplate** | Configuration template name | string | Specify the provisioning configuration template name (for autoprovisioning) |
|  |  |  |  |  |
| **instanceSSHKey** | Public SSH key for the user 'admin' | string | A valid public ssh key |
|  |  |  |  |  |
| **mgmtNIC** | Management Interface | string | Ephemeral Public IP (eth0)<br/>; Private IP (eth1); |
|  |  |  |  |  |
| **networkDefinedByRoutes** | Networks behind the Internal interface will be defined by routes.<br/>Set eth1 topology to define the networks behind this interface by the routes configured on the gateway | boolean | true; <br/>false; |
|  |  |  |  |  |
| **shell** | Admin shell | string | /etc/cli.sh;<br/>/bin/bash;<br/>/bin/csh;<br/>/bin/tcsh;<br/> |
|  |  |  |  |  |
| **allowUploadDownload** | Allow download from/upload to Check Point  | boolean | true; <br/>false; |
|  |  |  |  |  |
| **zone** | The zone determines what computing resources are available and where your data is stored and used | string | List of allowed [Regions and Zones](https://cloud.google.com/compute/docs/regions-zones?_ga=2.31926582.-962483654.1585043745) |
|  |  |  |  |  |
| **networks** | The external networks ID in which the gateways will reside and internal networks ID in which application servers reside. | list(string) | Available network in the chosen zone  |
|  |  |  |  |  |
| **subnetworks** | External and Internal subnet ID. Assigns the instance an IPv4 address from the subnetwork’s range. Instances in different subnetworks can communicate with each other using their internal IPs as long as they belong to the same network. | list(string) | Available subnetwork in the chosen network  |
|  |  |  |  |  |
| **enableIcmp** | Allow ICMP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **icmpSourceRanges** | Source IP ranges for ICMP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **enableTcp** | Allow TCP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **tcpSourceRanges** | Allow TCP traffic from the Internet | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway all ports are allowed. For management allowed ports are: 257,18191,18210,18264,22,443,18190,19009 [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **enableUdp** | Allow UDP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **udpSourceRanges** | Source IP ranges for UDP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only - all ports are allowed. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **enableSctp** | Allow SCTP traffic from the Internet | boolean | true; <br/>false;  |
|  |  |  |  |  |
| **sctpSourceRanges** | Source IP ranges for SCTP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only - all ports are allowed. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **enableEsp** | Allow ESP traffic from the Internet | boolean | true; <br/>false; |
|  |  |  |  |  |
| **espSourceRanges** | Source IP ranges for ESP traffic | string | Traffic is only allowed from sources within these IP address ranges. Use CIDR notation when entering ranges. For gateway only. [Learn more](https://cloud.google.com/vpc/docs/vpc?_ga=2.36703144.-962483654.1585043745#firewalls) |
|  |  |  |  |  |
| **machineType** | Machine types determine the specifications of your machines, such as the amount of memory, virtual cores, and persistent disk limits an instance will have | string | [Learn more about Machine Types](https://cloud.google.com/compute/docs/machine-types?hl=en_US&_ga=2.267871494.-962483654.1585043745) |
|  |  |  |  |  |
| **cpuUsage** | Target CPU usage (%).<br/>Autoscaling adds or removes instances in the group to maintain this level of CPU usage on each instance | number |  A number in the range 10 - 90 |
|  |  |  |  |  |
| **minInstances** | Minimum number of instances | number |  A number in the range 1 and the maximum number of instances |
|  |  |  |  |  |
| **maxInstances** | Maximum number of instances | number |  A number in the range the minimum number of instances and infinity |
|  |  |  |  |  |
| **diskType** | Disk type | string | pd-ssd;<br/>pd-standard;<br/>Storage space is much less expensive for a standard persistent disk. An SSD persistent disk is better for random IOPS or streaming throughput with low latency. [Learn more](https://cloud.google.com/compute/docs/disks/?hl=en_US&_ga=2.66020774.-962483654.1585043745#overview_of_disk_types)|
|  |  |  |  |  |
| **bootDiskSizeGb** | Disk size in GB | number | Persistent disk performance is tied to the size of the persistent disk volume. You are charged for the actual amount of provisioned disk space. [Learn more](https://cloud.google.com/compute/docs/disks/?hl=en_US&_ga=2.232680471.-962483654.1585043745#pdperformance)|
|  |  |  |  |  |
| **enableMonitoring** | Enable Stackdriver monitoring | boolean | true; <br/>false; |
|  |  |  |  |  |

## Example
    autoscalingVersion: "R81.10 Autoscaling"
    managementName: "mgmt"
    AutoProvTemplate: "template"
    instanceSSHKey: "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx imported-openssh-key"
    mgmtNIC: "Ephemeral Public IP (eth0)"
    networkDefinedByRoutes: true
    shell: "/bin/bash"
    allowUploadDownload: true
    zone: "asia-east1-a"
    networks: ["external-vpc", "internal-vpc"]
    subnetworks: ["frontend", "backend"]
    enableIcmp: true
    icmpSourceRanges: "0.0.0.0/0"
    enableTcp: false
    tcpSourceRanges: ""
    enableUdp: true
    udpSourceRanges: "0.0.0.0/0"
    enableSctp: false
    sctpSourceRanges: ""
    enableEsp: false
    espSourceRanges: ""
    machineType: "n1-standard-4"
    cpuUsage: 60
    minInstances: 2
    maxInstances: 10
    diskType: "pd-ssd"
    bootDiskSizeGb: 100
    enableMonitoring: false
    
## Notes
See [sk147032](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk147032) for revision history
