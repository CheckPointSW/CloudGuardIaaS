package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in aws/tgw-gwlb-master using terratest.
func TestTgwGwlbMaster(t *testing.T) {
	t.Parallel()

	// website::tag::1::Configure Terraform setting path to Terraform code, EC2 instance name, and AWS Region.
	terraformOptions := GetTerraformOptionsTgwGwlbMaster()

	// website::tag::4::At the end of the tests, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// website::tag::2::Run `terraform init` and `terraform apply` and fail the tests if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run 'terraform output' and validate output values
	ValidateOutputsTgwGwlbMaster(t, terraformOptions)
}

func GetTerraformOptionsTgwGwlbMaster() *terraform.Options {
	terraformOptions := &terraform.Options{
		TerraformDir: "../tgw-gwlb-master",

		// Variables passed to the module execution using -var options
		Vars: map[string]interface{}{
			"vpc_cidr":           vpcCIDR,
			"public_subnets_map": publicSubnetsMap,
			"tgw_subnets_map":    tgwSubnetsMap,
			"subnets_bit_length": subnetsBitLength,

			"availability_zones": availabilityZones,
			"number_of_AZs":      numberOfAZs,

			"nat_gw_subnet_1_cidr": "10.0.13.0/24",
			"nat_gw_subnet_2_cidr": "10.0.23.0/24",

			"gwlbe_subnet_1_cidr": "10.0.14.0/24",
			"gwlbe_subnet_2_cidr": "10.0.24.0/24",

			"key_name":                     keyName,
			"enable_volume_encryption":     enableVolumeEncryption,
			"volume_size":                  volumeSize,
			"enable_instance_connect":      enableInstanceConnect,
			"disable_instance_termination": disableInstanceTermination,
			"allow_upload_download":        allowUploadDownload,
			"management_server":            managementExpectedName,
			"configuration_template":       configurationTemplate,
			"admin_shell":                  adminShell,

			"gateway_load_balancer_name":       gwlbExpectedName,
			"target_group_name":                targetGroup1Name,
			"enable_cross_zone_load_balancing": enableCrossZoneLoadBalancing,

			"gateway_name":                           gatewayExpectedName,
			"gateway_instance_type":                  gatewayInstanceType,
			"minimum_group_size":                     autoscaleGroupExpectedCapacityMin,
			"maximum_group_size":                     autoscaleGroupExpectedCapacityMax,
			"gateway_version":                        version,
			"gateway_password_hash":                  passwordHash,
			"gateway_maintenance_mode_password_hash": passwordHash,
			"gateway_SICKey":                         SICKey,
			"gateways_provision_address_type":        gatewaysProvisionAddressType,
			"allocate_public_IP":                     allocatePublicIP,
			"enable_cloudwatch":                      enableCloudWatch,
			"gateway_bootstrap_script":               gatewayBootstrapScript,

			"management_deploy":                         managementDeploy,
			"management_instance_type":                  managementInstanceType,
			"management_version":                        version,
			"management_password_hash":                  passwordHash,
			"management_maintenance_mode_password_hash": passwordHash,
			"gateways_policy":                           gatewaysPolicy,
			"gateway_management":                        gatewayManagement,
			"admin_cidr":                                anywhereAddress,
			"gateways_addresses":                        anywhereAddress,

			"volume_type": volumeType,
		},

		// Set environment variables when running Terraform
		EnvVars: envVars,
	}
	return terraformOptions
}

func ValidateOutputsTgwGwlbMaster(t *testing.T, terraformOptions *terraform.Options) {
	outputDeployment := terraform.Output(t, terraformOptions, "Deployment")
	outputManagementPublicIP := terraform.Output(t, terraformOptions, "management_public_ip")
	outputGWLBARN := terraform.Output(t, terraformOptions, "gwlb_arn")
	outputGWLBServiceName := terraform.Output(t, terraformOptions, "gwlb_service_name")
	outputGWLBName := terraform.Output(t, terraformOptions, "gwlb_name")
	outputGWLBControllerName := terraform.Output(t, terraformOptions, "controller_name")
	outputConfigurationTemplateName := terraform.Output(t, terraformOptions, "template_name")

	assert.Equal(t, outputGWLBName, gwlbExpectedName)
	assert.Equal(t, outputGWLBControllerName, gwlbControlllerExpectedName)
	assert.Equal(t, outputConfigurationTemplateName, configurationTemplate)

	assert.NotEmpty(t, outputDeployment)
	assert.NotEmpty(t, outputManagementPublicIP)
	assert.NotEmpty(t, outputGWLBARN)
	assert.NotEmpty(t, outputGWLBServiceName)
}
