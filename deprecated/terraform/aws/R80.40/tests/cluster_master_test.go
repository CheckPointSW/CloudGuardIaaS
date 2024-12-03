package tests

import (
	"github.com/stretchr/testify/assert"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// Test the Terraform module in aws/cluster-master using terratest.
func TestClusterMaster(t *testing.T) {
	t.Parallel()

	// website::tag::1::Configure Terraform setting path to Terraform code, EC2 instance name, and AWS Region.
	terraformOptions := GetTerraformOptionsClusterMaster()
	terraformOptionsWithTarget := GetTerraformOptionsWithTargetClusterMaster()

	// website::tag::4::At the end of the tests, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// website::tag::2::Run `terraform init` and `terraform apply` and fail the tests if there are any errors
	terraform.InitAndApply(t, terraformOptionsWithTarget)
	terraform.Apply(t, terraformOptions)

	// Run 'terraform output' and validate output values
	ValidateOutputsClusterMaster(t, terraformOptions)
}

func GetTerraformOptionsClusterMaster() *terraform.Options {
	terraformOptions := &terraform.Options{
		TerraformDir: "../cluster-master",

		// Variables passed to the module execution using -var options. To change any value refer to globals.go
		Vars: map[string]interface{}{
			"vpc_cidr":            vpcCIDR,
			"public_subnets_map":  publicSubnetsMapSingle,
			"private_subnets_map": privateSubnetsMapSingle,
			"subnets_bit_length":  subnetsBitLength,

			"gateway_name":                 clusterGatewayExpectedName,
			"gateway_instance_type":        gatewayInstanceType,
			"key_name":                     keyName,
			"allocate_and_associate_eip":   allocateAndAssociatePublicEip,
			"volume_size":                  volumeSize,
			"volume_encryption":            volumeEncryption,
			"enable_instance_connect":      enableInstanceConnect,
			"disable_instance_termination": disableInstanceTermination,
			"instance_tags":                map[string]string{expectedTestTagKey: expectedTestTagValueClusterGateway},
			"predefined_role":              predefinedRole,

			"gateway_version":                        version,
			"admin_shell":                            adminShell,
			"gateway_SICKey":                         SICKey,
			"gateway_password_hash":                  passwordHash,
			"gateway_maintenance_mode_password_hash": passwordHash,

			"memberAToken": gatewaySmart1CloudToken,
			"memberBToken": gatewaySmart1CloudToken,

			"resources_tag_name":       resourcesTagName,
			"gateway_hostname":         gatewayHostname,
			"allow_upload_download":    allowUploadDownload,
			"enable_cloudwatch":        enableCloudWatch,
			"gateway_bootstrap_script": gatewayBootstrapScript,
			"primary_ntp":              primaryNtp,
			"secondary_ntp":            secondaryNtp,
		},

		// Set environment variables when running Terraform
		EnvVars: envVars,
	}
	return terraformOptions
}

func GetTerraformOptionsWithTargetClusterMaster() *terraform.Options {
	terraformOptionsWithTarget := GetTerraformOptionsClusterMaster()
	terraformOptionsWithTarget.Targets = []string{"aws_route_table.private_subnet_rtb"}

	return terraformOptionsWithTarget
}

func ValidateOutputsClusterMaster(t *testing.T, terraformOptions *terraform.Options) {
	outputAmiId := terraform.Output(t, terraformOptions, "ami_id")
	outputClusterPublicIP := terraform.Output(t, terraformOptions, "cluster_public_ip")
	outputMemberAEipPublicIP := terraform.Output(t, terraformOptions, "member_a_public_ip")
	outputMemberBEipPublicIP := terraform.Output(t, terraformOptions, "member_b_public_ip")
	outputMemberASSH := terraform.Output(t, terraformOptions, "member_a_ssh")
	outputMemberBSSH := terraform.Output(t, terraformOptions, "member_b_ssh")
	outputMemberAURL := terraform.Output(t, terraformOptions, "member_a_url")
	outputMemberBURL := terraform.Output(t, terraformOptions, "member_b_url")

	assert.NotEmpty(t, outputAmiId)
	assert.NotEmpty(t, outputClusterPublicIP)
	assert.NotEmpty(t, outputMemberAEipPublicIP)
	assert.NotEmpty(t, outputMemberBEipPublicIP)
	assert.NotEmpty(t, outputMemberASSH)
	assert.NotEmpty(t, outputMemberBSSH)
	assert.NotEmpty(t, outputMemberAURL)
	assert.NotEmpty(t, outputMemberBURL)
}
