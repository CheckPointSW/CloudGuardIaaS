package tests

import "fmt"

// AWS region for deployed resources
const region = "ca-central-1"

var envVars = map[string]string{
	"AWS_DEFAULT_REGION": region,
}

const availabilityZoneA = region + "a"

const availabilityZoneB = region + "b"

// Predefined prefix for deployed resources
const predefinedPrefix = "test"

// Predefined names for deployed resources
const gatewayPredefinedName = "CheckPoint-Gateway"

const standalonePredefinedName = "CheckPoint-Standalone"

const managementPredefinedName = "CheckPoint-Management"

const gwlbPredefinedName = "CheckPoint-GWLB"

const clusterGatewayPredefinedName = "CheckPoint-Cluster-Gateway"

const crossAZClusterGatewayPredefinedName = "CheckPoint-Cross-AZ-Cluster-Gateway"

const qsAutoscaleGatewayPredefinedName = "quickstart-security-gateway"

const qsAutoscaleProvisionTag = "quickstart"

const configurationTemplate = "configuration-template"

// Expected names for deployed resources
func getExpectedName(predefinedName string) string {
	return fmt.Sprintf("%s-%s", predefinedPrefix, predefinedName)
}

var gatewayExpectedName = getExpectedName(gatewayPredefinedName)

var standaloneExpectedName = getExpectedName(standalonePredefinedName)

var managementExpectedName = getExpectedName(managementPredefinedName)

var gwlbExpectedName = getExpectedName(gwlbPredefinedName)

var clusterGatewayExpectedName = getExpectedName(clusterGatewayPredefinedName)

var crossAZClusterGatewayExpectedName = getExpectedName(crossAZClusterGatewayPredefinedName)

var qsAutoscaleGatewayExpectedName = getExpectedName(qsAutoscaleGatewayPredefinedName)

// Autoscale group capacity configuration
const autoscaleGroupExpectedCapacityMin = 1

const autoscaleGroupExpectedCapacityMax = 1

const targetGroup1Name = "tf-test-target-group-1"

// Common parameters for deployed resources
const keyName = "tf-test"

const version = "R81.20-BYOL"

const standaloneVersion = "R81.20-BYOL"

const adminShell = "/bin/bash"

const gatewayBootstrapScript = "echo 'this is gateway bootstrap script' > /home/admin/bootstrap.txt"

const standaloneBootstrapScript = "echo 'this is standalone bootstrap script' > /home/admin/bootstrap.txt"

const passwordHash = "12345678"

const SICKey = "12345678"

const gatewayInstanceType = "c5.xlarge"

const standaloneInstanceType = gatewayInstanceType

const managementInstanceType = "m5.xlarge"

const volumeSize = 100

const volumeEncryption = "alias/aws/ebs"

const webServerInstanceType = "t3.micro"

const webServerAMI = "ami-0718a739967397e7d"

const volumeType = "gp3"

const anywhereAddress = "0.0.0.0/0"

const loadBalancersType = "Network Load Balancer"

const loadBalancerProtocol = "TCP"

const certificate = ""

const servicePort = "80"

const enableVolumeEncryption = true

const allocatePublicIP = true

const allocateAndAssociatePublicEip = true

const allowUploadDownload = true

const enableInstanceConnect = true

const enableCloudWatch = false

const connectionAcceptanceRequired = false

const enableCrossZoneLoadBalancing = true

const managementDeploy = true

const webServerDeploy = true

const gatewaysBlades = true

const disableInstanceTermination = false

const gatewaySmart1CloudToken = ""

const predefinedRole = ""

const primaryNtp = ""

const secondaryNtp = ""

const expectedTestTagKey = "test_tag"

const expectedTestTagValueClusterGateway = "cluster_gateway_tf"

const expectedTestTagValueGateway = "gateway_tf"

const autoscaleGroupName = "CheckPoint-ASG"

const resourcesTagName = "tag-name"

const gatewayHostname = "gw-hostname"

const gatewaysProvisionAddressType = "private"

const gatewaysPolicy = "Standard"

const gatewayManagement = "Locally managed"

// New VPC configuration
const vpcCIDR = "10.0.0.0/16"

var publicSubnetsMap = map[string]int{availabilityZoneA: 1, availabilityZoneB: 3}

var privateSubnetsMap = map[string]int{availabilityZoneA: 2, availabilityZoneB: 4}

var publicSubnetsMapSingle = map[string]int{availabilityZoneA: 1}

var privateSubnetsMapSingle = map[string]int{availabilityZoneA: 2}

var tgwSubnetsMap = map[string]int{availabilityZoneA: 5, availabilityZoneB: 6}

var availabilityZones = []string{availabilityZoneA, availabilityZoneB}

const numberOfAZs = 2

const subnetsBitLength = 8

// Controller expected names
const gwlbControlllerExpectedName = "gwlb-controller"
