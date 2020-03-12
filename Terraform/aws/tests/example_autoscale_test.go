package tests

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// An example of how to tests the Terraform module in examples/autoscale-example using Terratest.
func TestAutoscaleExample(t *testing.T) {
	t.Parallel()

	// Predefined testing variables
	predefinedPrefix := "test"
	predefinedInstancesName := "CheckPoint-ASG-gateway"

	// Define expected results for validations
	expectedInstancesName := fmt.Sprintf("%s-%s", predefinedPrefix, predefinedInstancesName)
	expectedAsgCapacityMin := 1
	expectedAsgCapacityMax := 1

	awsRegion := "ap-east-1"

	// variable lists
	vpcId := "vpc-048eeb284b845ef72"
	subnetsList := []string{"subnet-0dbc66fd0d99448ff", "subnet-06b0968432f7593b2"}
	targetGroupsList := []string{"arn:aws:elasticloadbalancing:ap-east-1:406406155863:targetgroup/mbd-ext-tg1/45149fd2f047f69b", "arn:aws:elasticloadbalancing:ap-east-1:406406155863:targetgroup/mbd-ext-tg2/8c4ef3586417057c"}

	// website::tag::1::Configure Terraform setting path to Terraform code, EC2 instance name, and AWS Region.
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/example_autoscale",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"region":				 awsRegion,
			"prefix":                predefinedPrefix,
			"asg_name":              "CheckPoint-ASG",
			"vpc_id":                vpcId,
            "subnet_ids":            subnetsList,
            "managementServer":      "mgmt_test",
            "configurationTemplate": "tmpl_test",
            "instances_name":        predefinedInstancesName,
            "key_name":              "marlenbd",
            "minimum_group_size":    expectedAsgCapacityMin,
            "maximum_group_size":    expectedAsgCapacityMax,
            "target_groups":         targetGroupsList,
            "admin_shell":           "/bin/bash",
            "version_license":       "R80.40-PAYG-NGTP-GW",
            "password_hash":         "$1$hhdwDdRG$5NOrisaYtANfeCl1zK3EX1",
            "SICKey":                "12345678",
            "allow_upload_download": true,
            "enable_cloudwatch":     false,
            "bootstrap_script": "touch /home/admin/terratest_validation.txt",
            "proxy_elb_type": "internet-facing",
            "proxy_elb_clients": "0.0.0.0/0",
            "proxy_elb_port": 8080,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	// website::tag::4::At the end of the tests, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// website::tag::2::Run `terraform init` and `terraform apply` and fail the tests if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run 'terraform output' to get the value of an output variable
	asgName := terraform.Output(t, terraformOptions, "autoscale-autoscaling_group_name")

	asgCapacityInfo := aws.GetCapacityInfoForAsg(t, asgName, awsRegion)
    awsInstancesIds := aws.GetInstanceIdsForAsg(t, asgName, awsRegion)

    // website::tag::3::
    // Verify the ASG's instances contain the expected Name tag value
	for _, instanceId := range awsInstancesIds {
		// Look up the tags for the given Instance ID
        instanceTags := aws.GetTagsForEc2Instance(t, awsRegion, instanceId)

        nameTag, containsNameTag := instanceTags["Name"]
        assert.True(t, containsNameTag)
        assert.Equal(t, expectedInstancesName, nameTag)
    }
    // Verify the ASG capacity info matches the expected
    assert.Equal(t, int64(expectedAsgCapacityMax), asgCapacityInfo.MaxCapacity)
    assert.Equal(t, int64(expectedAsgCapacityMin), asgCapacityInfo.MinCapacity)
    assert.Equal(t, int64(expectedAsgCapacityMin), asgCapacityInfo.CurrentCapacity)
    assert.Equal(t, int64(expectedAsgCapacityMin), asgCapacityInfo.DesiredCapacity)

    // waiter for user data to complete (timeout 10m)
	// todo
}