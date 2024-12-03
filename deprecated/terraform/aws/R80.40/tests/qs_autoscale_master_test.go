package tests

import (
	"github.com/gruntwork-io/terratest/modules/aws"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in qs-autoscale-master using terratest.
func TestQsAutoscaleMaster(t *testing.T) {
	t.Parallel()

	// website::tag::1::Configure Terraform setting path to Terraform code, EC2 instance name, and AWS Region.
	terraformOptions := GetTerraformOptionsQsAutoscaleMaster()

	// website::tag::4::At the end of the tests, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// website::tag::2::Run `terraform init` and `terraform apply` and fail the tests if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run 'terraform output' and validate output values
	ValidateOutputsQsAutoscaleMaster(t, terraformOptions)
}

func GetTerraformOptionsQsAutoscaleMaster() *terraform.Options {
	terraformOptions := &terraform.Options{
		TerraformDir: "../qs-autoscale-master",

		// Variables passed to the module execution using -var options
		Vars: map[string]interface{}{
			"prefix":   predefinedPrefix,
			"asg_name": autoscaleGroupName,

			"vpc_cidr":            vpcCIDR,
			"public_subnets_map":  publicSubnetsMap,
			"private_subnets_map": privateSubnetsMap,
			"subnets_bit_length":  subnetsBitLength,

			"key_name":                     keyName,
			"enable_volume_encryption":     enableVolumeEncryption,
			"enable_instance_connect":      enableInstanceConnect,
			"disable_instance_termination": disableInstanceTermination,
			"allow_upload_download":        allowUploadDownload,
			"provision_tag":                qsAutoscaleProvisionTag,

			"load_balancers_type":    loadBalancersType,
			"load_balancer_protocol": loadBalancerProtocol,
			"certificate":            certificate,
			"service_port":           servicePort,

			"gateway_instance_type":                  gatewayInstanceType,
			"gateways_min_group_size":                autoscaleGroupExpectedCapacityMin,
			"gateways_max_group_size":                autoscaleGroupExpectedCapacityMax,
			"gateway_version":                        version,
			"gateway_password_hash":                  passwordHash,
			"gateway_maintenance_mode_password_hash": passwordHash,
			"gateway_SICKey":                         SICKey,
			"enable_cloudwatch":                      enableCloudWatch,

			"management_deploy":                         managementDeploy,
			"management_instance_type":                  managementInstanceType,
			"management_version":                        version,
			"management_password_hash":                  passwordHash,
			"management_maintenance_mode_password_hash": passwordHash,
			"gateways_policy":                           gatewaysPolicy,
			"gateways_blades":                           gatewaysBlades,
			"admin_cidr":                                anywhereAddress,
			"gateways_addresses":                        anywhereAddress,

			"servers_deploy":        webServerDeploy,
			"servers_instance_type": webServerInstanceType,
			"server_ami":            webServerAMI,
		},

		// Set environment variables when running Terraform
		EnvVars: envVars,
	}
	return terraformOptions
}

func ValidateOutputsQsAutoscaleMaster(t *testing.T, terraformOptions *terraform.Options) {
	outputVpcId := terraform.Output(t, terraformOptions, "vpc_id")
	outputPublicSubnetsIdsList := terraform.Output(t, terraformOptions, "public_subnets_ids_list")
	outputPrivateSubnetsIdsList := terraform.Output(t, terraformOptions, "private_subnets_ids_list")
	outputManagementInstanceName := terraform.Output(t, terraformOptions, "management_name")
	outputLBUrl := terraform.Output(t, terraformOptions, "load_balancer_url")
	outputExternalLBId := terraform.Output(t, terraformOptions, "external_load_balancer_arn")
	outputInternalLBId := terraform.Output(t, terraformOptions, "internal_load_balancer_arn")
	outputExternalTGId := terraform.Output(t, terraformOptions, "external_lb_target_group_arn")
	outputInternalTGId := terraform.Output(t, terraformOptions, "internal_lb_target_group_arn")
	outputGwsASGId := terraform.Output(t, terraformOptions, "autoscale_autoscaling_group_arn")
	outputSecurityGroup := terraform.Output(t, terraformOptions, "autoscale_security_group_id")

	asgName := terraform.Output(t, terraformOptions, "autoscale_autoscaling_group_name")
	asgCapacityInfo := aws.GetCapacityInfoForAsg(t, asgName, region)
	awsInstancesIds := aws.GetInstanceIdsForAsg(t, asgName, region)

	// website::tag::3::
	// Verify the ASG's Gateway instances contain the expected Name tag value
	for _, instanceId := range awsInstancesIds {
		// Look up the tags for the given Instance ID
		instanceTags := aws.GetTagsForEc2Instance(t, region, instanceId)

		nameTag, containsNameTag := instanceTags["Name"]
		assert.True(t, containsNameTag)
		assert.Equal(t, qsAutoscaleGatewayExpectedName, nameTag)
	}

	// Verify the ASG capacity info matches the expected
	assert.Equal(t, int64(autoscaleGroupExpectedCapacityMax), asgCapacityInfo.MaxCapacity)
	assert.Equal(t, int64(autoscaleGroupExpectedCapacityMin), asgCapacityInfo.MinCapacity)
	assert.Equal(t, int64(autoscaleGroupExpectedCapacityMin), asgCapacityInfo.CurrentCapacity)
	assert.Equal(t, int64(autoscaleGroupExpectedCapacityMin), asgCapacityInfo.DesiredCapacity)

	assert.NotEmpty(t, outputManagementInstanceName)
	assert.NotEmpty(t, outputVpcId)
	assert.NotEmpty(t, outputPublicSubnetsIdsList)
	assert.NotEmpty(t, outputPrivateSubnetsIdsList)
	assert.NotEmpty(t, outputLBUrl)
	assert.NotEmpty(t, outputExternalLBId)
	assert.NotEmpty(t, outputInternalLBId)
	assert.NotEmpty(t, outputExternalTGId)
	assert.NotEmpty(t, outputInternalTGId)
	assert.NotEmpty(t, outputGwsASGId)
	assert.NotEmpty(t, outputSecurityGroup)
}
