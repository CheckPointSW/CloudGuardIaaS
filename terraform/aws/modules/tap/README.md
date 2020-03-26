# Check Point Traffic Access Point (TAP) Terraform module for AWS

Terraform module which deploys a TAP solution in an existing VPC on AWS.

To learn about Check Point's TAP solution, click [here](). // TODO


These types of Terraform resources are supported:
* [AWS Instance](https://www.terraform.io/docs/providers/aws/r/instance.html) - TAP Gateway
* [AWS CloudFormation Stack](https://www.terraform.io/docs/providers/aws/r/cloudformation_stack.html) - creates Traffic Mirror Filter and Target 
* [AWS Lambdas](https://www.terraform.io/docs/providers/aws/r/lambda_function.html) - TAP Lambda, TAP Termination Lambda

## Usage
Variables are configured in **terraform.tfvars** file as follows:
```
region = "us-east-1"

// --- VPC Network Configuration ---
vpc_id = "vpc-12345678"
external_subnet_id = "subnet-abc123"
internal_subnet_id = "subnet-def456"
resources_tag_name = "env1"

// --- TAP Configuration ---
registration_key = "10:10:10:10:10:10"
vxlan_id = 10
blacklist_tags = {
  env = "staging"
  state = "stable"
}
schedule_scan_interval = 60

// --- EC2 Instance Configuration ---
instance_name = "tap-gateway"
instance_type = "c5.xlarge"
key_name = "privatekey"
password_hash = "12345678"

// --- Check Point Settings ---
version_license = "R80.40-PAYG-NGTP-GW"
```
**main.tf**:
```
provider "aws" {
  region = var.region
}

module "tap" {
  source = "../../modules/tap"

  // --- VPC Network Configuration ---
  vpc_id = var.vpc_id
  external_subnet_id = var.external_subnet_id
  internal_subnet_id = var.internal_subnet_id
  resources_tag_name = var.resources_tag_name

  // --- TAP Configuration ---
  registration_key = var.registration_key
  vxlan_id = var.vxlan_id
  blacklist_tags = var.blacklist_tags
  schedule_scan_interval = var.schedule_scan_interval

  // --- EC2 Instance Configuration ---
  instance_name = var.instance_name
  instance_type = var.instance_type
  key_name = var.key_name
  password_hash = var.password_hash

  // --- Check Point Settings ---
  version_license = var.version_license
}
```


This module creates a Check Point TAP Gateway instance in the VPC specified by the user, 
along with traffic mirror filter and target, and two lambda functions: TAP Lambda and TAP Termination Lambda.

Once the Check Point TAP Gateway instance is deployed, the TAP Lambda is invoked and scans the entire 
VPC for mirrorable NITRO instances.


### TAP Lambda:

#### IAM role
The module creates an IAM role for the TAP Lambda, named 'chkp_iam_tap_lambda' suffixed with a uuid.
This role is granted minimum permissions for the Lambda to execute.

#### Responsibilities

1. Invoked by Terraform once the Check Point TAP Gateway instance is deployed.
    1. Scans the VPC for mirrorable instances
    2. Creates traffic mirror sessions between the TAP Gateway traffic mirror target 
    and the primary ENI of non-blacklisted instances
    3. Skips traffic mirror session creation for blacklisted instances

2. Invoked by an EC2 event: Every instance in the VPC that changes its state to 'Running'.
    1. Updates TAP for triggered instance - If not blacklisted and not TAPed, 
    creates traffic mirror session to the TAP Gateway traffic mirror target.
    If blacklisted and TAPed, deletes traffic mirror session with the TAP Gateway target
    2. Scans VPC and updates TAP for all mirrorable instances (see 2.i)
 
3. Invoked by a scheduled event: every X minutes, configured by the 'schedule_scan_interval' variable (default = 60).
    1. Scans the VPC for mirrorable instances
    2. Updates TAP for all mirrorable instances in the VPC (see 2.i)


#### Instances blacklisting:

This module supports tag based blacklist mechanism to avoid TAP for desired instances. 

The Terraform TAP module holds a 'blacklist_tags' variable of type map(string).
The 'blacklist_tags' variable consists of key value pairs representing tag-key and tag-value pairs. 

The TAP Lambda will create traffic mirror sessions only for instances which **do not** hold any of 
these tag pairs. Instances with any of these tag pairs will not be TAPed by the TAP Lambda function. 
If a blacklisted instance is already TAPed, the TAP Lambda will act accordingly and 
delete the traffic mirror session.

During the solution deployment, the 'blacklist_tags' variable's values are joined to a string in the
following structure: "key1=value1:key2-value2:key3=value3" and so on.
This string is passed as 'TAP_BLACKLIST' environment variable to the TAP Lambda.
You can update the blacklist tags list by editing the TAP Lambda 'TAP_BLACKLIST' environment variable.
The structure "key1=value1:key2-value2:key3=value3" of the variable must be maintained.


### TAP Termination Lambda:
 
 This Lambda should be manually invoked **prior** to destroying the Terraform environment.
 The environment destruction **will fail** if skipping the Termination Lambda invocation.

#### IAM role
The module creates an IAM role for the TAP Termination Lambda, named 'chkp_iam_tap_termination_lambda' suffixed with a uuid.
This role is granted minimum permissions for the Lambda to execute.
 
#### Responsibilities:
 
Lambda deletes <u>all</u> traffic mirror sessions associated with the TAP Gateway's target.
This step is crucial before environment destruction in order for destruction to finish successfully
(an alternative way is to navigate to AWS traffic mirror sessions page and manually 
delete the relevant sessions).



## Inputs
| Name          | Description   | Type          | Allowed values | Default       | Required      |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| vpc_id        | The VPC id in which to deploy  | string  | n/a | n/a  | yes |
| external_subnet_id | The external subnet of the security gateway (internet access)  | string  | n/a | n/a  | yes |
| internal_subnet_id | The internal subnet of the security gateway. This subnet will be connected to the mirrored sources. | string  | n/a | n/a  | yes |
| resources_tag_name | (Optional) Resources prefix tag  | string  | n/a | ""  | no |
|         |   |   |  |   |  |
| registration_key | The gateway registration key to Check Point NOW cloud | string  | n/a | n/a | yes |
| vxlan_id | (Optional) VXLAN ID (number) for mirroring sessions  | number  | n/a | 1  | no |
| blacklist_tags |Key value pairs of tag key and tag value. Instances with any of these tag pairs will not be TAPed | map(string)  | n/a | {}  | no |
| schedule_scan_interval | (minutes) Lambda will scan the VPC every X minutes for TAP updates | number  | n/a | 60  | no |
|         |   |   |  |   |  |
| instance_name | AWS instance name to launch  | string  | n/a | "CP-TAP-Gateway-tf"  | no |
| instance_type | AWS instance type  | string  | n/a | c5.xlarge  | no |
| key_name | The EC2 Key Pair name to allow SSH access to the instances  | string  | n/a | n/a  | yes |
| password_hash | (Optional) Admin user's password hash (use command \"openssl passwd -1 PASSWORD\" to get the PASSWORD's hash)  | string  | n/a | n/a  | yes |
|         |   |   |  |   |  |
| version_license | Version and license of the Check Point Security Gateway  | string  | - R80.40-BYOL-GW <br/> - R80.40-PAYG-NGTP-GW <br/> - R80.40-PAYG-NGTX-GW | R80.40-PAYG-NGTP-GW  | no |



## Outputs
| Name  | Description |
| ------------- | ------------- |
| tap-gateway_instance_id  | The instance id of the deployed Check Point TAP Gateway  |
| gateway_instance_name  | The instance name of the deployed Check Point TAP Gateway  |
| gateway_instance_public_ip  | The public ip address of the deployed Check Point TAP Gateway  |
| traffic_mirror_filter_id  | The traffic mirror filter id created during deployment by the 'tap_target_and_filter' stack  |
| traffic_mirror_target_id  | The traffic mirror target id pointing to the TAP Gateway's internal ENI - created during deployment by the 'tap_target_and_filter' stack  |
| tap_lambda_name  | TAP main lambda name (responsible for creating and deleting traffic mirror sessions with the TAP Gateway's target)  |
| tap_lambda_description  | TAP main lambda description  |
| termination_lambda_name  | TAP termination lambda name (deletes all traffic mirror sessions with the TAP Gateway's target)  |
| termination_lambda_description  | TAP termination lambda description  |

## Authors



## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details
