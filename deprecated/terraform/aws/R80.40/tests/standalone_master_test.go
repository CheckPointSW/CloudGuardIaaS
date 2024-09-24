package tests

import (
	"github.com/gruntwork-io/terratest/modules/aws"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in aws/standalone-master using terratest.
func TestStandaloneMaster(t *testing.T) {
	t.Parallel()

	// website::tag::1::Configure Terraform setting path to Terraform code, EC2 instance name, and AWS Region.
	terraformOptions := GetTerraformOptionsStandaloneMaster()
	terraformOptionsWithTarget := GetTerraformOptionsWithTargetStandaloneMaster()

	// website::tag::4::At the end of the tests, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// website::tag::2::Run `terraform init` and `terraform apply` and fail the tests if there are any errors
	terraform.InitAndApply(t, terraformOptionsWithTarget)
	terraform.Apply(t, terraformOptions)

	// Run 'terraform output' and validate output values
	ValidateOutputsStandaloneMaster(t, terraformOptions)
}

func GetTerraformOptionsStandaloneMaster() *terraform.Options {
	terraformOptions := &terraform.Options{
		TerraformDir: "../standalone-master",

		// Variables passed to the module execution using -var options
		Vars: map[string]interface{}{
			"vpc_cidr":            vpcCIDR,
			"public_subnets_map":  publicSubnetsMapSingle,
			"private_subnets_map": privateSubnetsMapSingle,
			"subnets_bit_length":  subnetsBitLength,

			"standalone_name":              standaloneExpectedName,
			"standalone_instance_type":     standaloneInstanceType,
			"key_name":                     keyName,
			"allocate_and_associate_eip":   allocateAndAssociatePublicEip,
			"volume_size":                  volumeSize,
			"volume_encryption":            volumeEncryption,
			"enable_instance_connect":      enableInstanceConnect,
			"disable_instance_termination": disableInstanceTermination,
			"instance_tags":                map[string]string{expectedTestTagKey: expectedTestTagValueGateway},

			"standalone_version":                        standaloneVersion,
			"admin_shell":                               adminShell,
			"standalone_password_hash":                  passwordHash,
			"standalone_maintenance_mode_password_hash": passwordHash,

			"resources_tag_name":          resourcesTagName,
			"standalone_hostname":         gatewayHostname,
			"allow_upload_download":       allowUploadDownload,
			"enable_cloudwatch":           enableCloudWatch,
			"standalone_bootstrap_script": standaloneBootstrapScript,
			"primary_ntp":                 primaryNtp,
			"secondary_ntp":               secondaryNtp,
			"admin_cidr":                  anywhereAddress,
			"gateway_addresses":           anywhereAddress,
		},

		// Set environment variables when running Terraform
		EnvVars: envVars,
	}
	return terraformOptions
}

func GetTerraformOptionsWithTargetStandaloneMaster() *terraform.Options {
	terraformOptionsWithTarget := GetTerraformOptionsStandaloneMaster()
	terraformOptionsWithTarget.Targets = []string{"aws_route_table.private_subnet_rtb"}

	return terraformOptionsWithTarget
}

func ValidateOutputsStandaloneMaster(t *testing.T, terraformOptions *terraform.Options) {
	outputVpcId := terraform.Output(t, terraformOptions, "vpc_id")
	outputInternalRouteTableId := terraform.Output(t, terraformOptions, "internal_rtb_id")
	outputVpcPublicSubnetsIdsList := terraform.Output(t, terraformOptions, "vpc_public_subnets_ids_list")
	outputVpcPrivateSubnetsIdsList := terraform.Output(t, terraformOptions, "vpc_private_subnets_ids_list")
	outputStandaloneInstanceId := terraform.Output(t, terraformOptions, "standalone_instance_id")
	outputStandaloneInstanceName := terraform.Output(t, terraformOptions, "standalone_instance_name")
	outputStandalonePublicIP := terraform.Output(t, terraformOptions, "standalone_public_ip")
	outputStandaloneSSH := terraform.Output(t, terraformOptions, "standalone_ssh")
	outputStandaloneURL := terraform.Output(t, terraformOptions, "standalone_url")

	// website::tag::3::
	// Verify the Standalone's instances contain the expected Name tag value
	instanceTags := aws.GetTagsForEc2Instance(t, region, outputStandaloneInstanceId)
	nameTag, containsNameTag := instanceTags["Name"]
	assert.True(t, containsNameTag)
	assert.Equal(t, standaloneExpectedName, nameTag)
	assert.Equal(t, standaloneExpectedName, outputStandaloneInstanceName)

	testTag, containsTestTag := instanceTags[expectedTestTagKey]
	assert.True(t, containsTestTag)
	assert.Equal(t, expectedTestTagValueGateway, testTag)

	assert.NotEmpty(t, outputVpcId)
	assert.NotEmpty(t, outputInternalRouteTableId)
	assert.NotEmpty(t, outputVpcPublicSubnetsIdsList)
	assert.NotEmpty(t, outputVpcPrivateSubnetsIdsList)
	assert.NotEmpty(t, outputStandaloneInstanceId)
	assert.NotEmpty(t, outputStandaloneInstanceName)
	assert.NotEmpty(t, outputStandalonePublicIP)
	assert.NotEmpty(t, outputStandaloneSSH)
	assert.NotEmpty(t, outputStandaloneURL)
}
