package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in aws/tgw-asg-master using terratest.
func TestTgwAsgMaster(t *testing.T) {
	t.Parallel()

	// website::tag::1::Configure Terraform setting path to Terraform code, EC2 instance name, and AWS Region.
	terraformOptions := GetTerraformOptionsTgwAsgMaster()

	// website::tag::4::At the end of the tests, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// website::tag::2::Run `terraform init` and `terraform apply` and fail the tests if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run 'terraform output' and validate output values
	ValidateOutputsTgwAsgMaster(t, terraformOptions)
}

func GetTerraformOptionsTgwAsgMaster() *terraform.Options {
	terraformOptions := &terraform.Options{
		TerraformDir: "../tgw-asg-master",

		// Variables passed to the module execution using -var options
		Vars: map[string]interface{}{
			"vpc_cidr":           vpcCIDR,
			"public_subnets_map": publicSubnetsMap,
			"subnets_bit_length": subnetsBitLength,

			"key_name":                     keyName,
			"enable_volume_encryption":     enableVolumeEncryption,
			"enable_instance_connect":      enableInstanceConnect,
			"disable_instance_termination": disableInstanceTermination,
			"allow_upload_download":        allowUploadDownload,

			"gateway_name":                           crossAZClusterGatewayExpectedName,
			"gateway_instance_type":                  gatewayInstanceType,
			"gateways_min_group_size":                autoscaleGroupExpectedCapacityMin,
			"gateways_max_group_size":                autoscaleGroupExpectedCapacityMax,
			"gateway_version":                        version,
			"gateway_password_hash":                  passwordHash,
			"gateway_maintenance_mode_password_hash": passwordHash,
			"gateway_SICKey":                         SICKey,
			"enable_cloudwatch":                      enableCloudWatch,
			"asn":                                    6500,

			"management_deploy":                         managementDeploy,
			"management_instance_type":                  managementInstanceType,
			"management_version":                        version,
			"management_password_hash":                  passwordHash,
			"management_maintenance_mode_password_hash": passwordHash,
			"management_permissions":                    "Create with read-write permissions",
			"management_predefined_role":                predefinedRole,
			"gateways_blades":                           gatewaysBlades,
			"admin_cidr":                                anywhereAddress,
			"gateways_addresses":                        anywhereAddress,
			"gateway_management":                        gatewayManagement,

			"control_gateway_over_public_or_private_address": "private",
			"management_server":      managementExpectedName,
			"configuration_template": configurationTemplate,
		},

		// Set environment variables when running Terraform
		EnvVars: envVars,
	}
	return terraformOptions
}

func ValidateOutputsTgwAsgMaster(t *testing.T, terraformOptions *terraform.Options) {
	outputVpcId := terraform.Output(t, terraformOptions, "vpc_id")
	outputVpcPublicSubnetsIdsList := terraform.Output(t, terraformOptions, "public_subnets_ids_list")
	outputManagementInstanceName := terraform.Output(t, terraformOptions, "management_instance_name")
	outputConfigurationTemplate := terraform.Output(t, terraformOptions, "configuration_template")
	outputControllerName := terraform.Output(t, terraformOptions, "controller_name")
	outputManagementPublicIP := terraform.Output(t, terraformOptions, "management_public_ip")
	outputManagementURL := terraform.Output(t, terraformOptions, "management_url")
	outputAutoscalingGroupName := terraform.Output(t, terraformOptions, "autoscaling_group_name")

	assert.NotEmpty(t, outputVpcId)
	assert.NotEmpty(t, outputVpcPublicSubnetsIdsList)
	assert.NotEmpty(t, outputManagementInstanceName)
	assert.NotEmpty(t, outputConfigurationTemplate)
	assert.NotEmpty(t, outputControllerName)
	assert.NotEmpty(t, outputManagementPublicIP)
	assert.NotEmpty(t, outputManagementURL)
	assert.NotEmpty(t, outputAutoscalingGroupName)
}
