package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in aws/gateway-master using terratest.
func TestGatewayMaster(t *testing.T) {
	t.Parallel()

	// website::tag::1::Configure Terraform setting path to Terraform code, EC2 instance name, and AWS Region.
	terraformOptions := GetTerraformOptionsGatewayMaster()
	terraformOptionsWithTarget := GetTerraformOptionsWithTargetGatewayMaster()

	// website::tag::4::At the end of the tests, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// website::tag::2::Run `terraform init` and `terraform apply` and fail the tests if there are any errors
	terraform.InitAndApply(t, terraformOptionsWithTarget)
	terraform.Apply(t, terraformOptions)

	// Run 'terraform output' and validate output values
	ValidateOutputsGatewayMaster(t, terraformOptions)
}

func GetTerraformOptionsGatewayMaster() *terraform.Options {
	terraformOptions := &terraform.Options{
		TerraformDir: "../gateway-master",

		// Variables passed to the module execution using -var options
		Vars: map[string]interface{}{
			"vpc_cidr":            vpcCIDR,
			"public_subnets_map":  publicSubnetsMapSingle,
			"private_subnets_map": privateSubnetsMapSingle,
			"subnets_bit_length":  subnetsBitLength,

			"gateway_name":                 gatewayExpectedName,
			"gateway_instance_type":        gatewayInstanceType,
			"key_name":                     keyName,
			"allocate_and_associate_eip":   allocateAndAssociatePublicEip,
			"volume_size":                  volumeSize,
			"volume_encryption":            volumeEncryption,
			"enable_instance_connect":      enableInstanceConnect,
			"disable_instance_termination": disableInstanceTermination,
			"instance_tags":                map[string]string{expectedTestTagKey: expectedTestTagValueGateway},

			"gateway_version":                        version,
			"admin_shell":                            adminShell,
			"gateway_SICKey":                         SICKey,
			"gateway_password_hash":                  passwordHash,
			"gateway_maintenance_mode_password_hash": passwordHash,

			"gateway_TokenKey": gatewaySmart1CloudToken,

			"resources_tag_name":       resourcesTagName,
			"gateway_hostname":         gatewayHostname,
			"allow_upload_download":    allowUploadDownload,
			"enable_cloudwatch":        enableCloudWatch,
			"gateway_bootstrap_script": gatewayBootstrapScript,
			"primary_ntp":              primaryNtp,
			"secondary_ntp":            secondaryNtp,

			"control_gateway_over_public_or_private_address": gatewaysProvisionAddressType,
			"management_server":      managementExpectedName,
			"configuration_template": configurationTemplate,
		},

		// Set environment variables when running Terraform
		EnvVars: envVars,
	}
	return terraformOptions
}

func GetTerraformOptionsWithTargetGatewayMaster() *terraform.Options {
	terraformOptionsWithTarget := GetTerraformOptionsGatewayMaster()
	terraformOptionsWithTarget.Targets = []string{"aws_route_table.private_subnet_rtb"}

	return terraformOptionsWithTarget
}

func ValidateOutputsGatewayMaster(t *testing.T, terraformOptions *terraform.Options) {
	outputVpcId := terraform.Output(t, terraformOptions, "vpc_id")
	outputInternalRouteTableId := terraform.Output(t, terraformOptions, "internal_rtb_id")
	outputVpcPublicSubnetsIdsList := terraform.Output(t, terraformOptions, "vpc_public_subnets_ids_list")
	outputVpcPrivateSubnetsIdsList := terraform.Output(t, terraformOptions, "vpc_private_subnets_ids_list")
	outputAmiId := terraform.Output(t, terraformOptions, "ami_id")
	outputPermissiveSgId := terraform.Output(t, terraformOptions, "permissive_sg_id")
	outputPermissiveSgName := terraform.Output(t, terraformOptions, "permissive_sg_name")
	outputGatewayUrl := terraform.Output(t, terraformOptions, "gateway_url")
	outputGatewayPublicIp := terraform.Output(t, terraformOptions, "gateway_public_ip")
	outputGatewayInstanceId := terraform.Output(t, terraformOptions, "gateway_instance_id")
	outputGatewayInstanceName := terraform.Output(t, terraformOptions, "gateway_instance_name")

	instanceTags := aws.GetTagsForEc2Instance(t, region, outputGatewayInstanceId)
	nameTag, containsNameTag := instanceTags["Name"]
	assert.True(t, containsNameTag)
	assert.Equal(t, gatewayExpectedName, nameTag)
	assert.Equal(t, gatewayExpectedName, outputGatewayInstanceName)

	testTag, containsTestTag := instanceTags[expectedTestTagKey]
	assert.True(t, containsTestTag)
	assert.Equal(t, expectedTestTagValueGateway, testTag)

	assert.NotEmpty(t, outputVpcId)
	assert.NotEmpty(t, outputInternalRouteTableId)
	assert.NotEmpty(t, outputVpcPublicSubnetsIdsList)
	assert.NotEmpty(t, outputVpcPrivateSubnetsIdsList)
	assert.NotEmpty(t, outputAmiId)
	assert.NotEmpty(t, outputPermissiveSgId)
	assert.NotEmpty(t, outputPermissiveSgName)
	assert.NotEmpty(t, outputGatewayUrl)
	assert.NotEmpty(t, outputGatewayPublicIp)
	assert.NotEmpty(t, outputGatewayInstanceId)
	assert.NotEmpty(t, outputGatewayInstanceName)
}
