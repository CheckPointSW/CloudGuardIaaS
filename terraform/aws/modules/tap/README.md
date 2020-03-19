# CheckPoint Traffic Access Point (TAP) Terraform module for AWS

Terrafrom module which deploys a TAP solution in an existing VPC on AWS.

To learn about Check Point's TAP solution, click [here]().


These types of Terraform resources are supported:
* [AWS Instance](https://www.terraform.io/docs/providers/aws/r/instance.html)
* [Traffic mirror filter and target template]() // todo
* [Traffic mirror sessions]() // todo
* [Lambda](https://www.terraform.io/docs/providers/aws/r/lambda_function.html)

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
vxlan_ids = [10]
blacklist_tags = {
  env = "staging"
  state = "stable"
}

// --- EC2 Instance Configuration ---
instance_name = "tap-gateway"
instance_type = "c5.xlarge"
key_name = "privatekey"
password_hash = "12345678"
is_allocate_and_associate_elastic_ip = true
is_enable_instance_connect = false

// --- Check Point Settings ---
version_license = "R80.30-PAYG-NGTP-GW"
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
  vxlan_ids = var.vxlan_ids
  blacklist_tags = var.blacklist_tags
  schedule_scan_period = var.schedule_scan_period

  // --- EC2 Instance Configuration ---
  instance_name = var.instance_name
  instance_type = var.instance_type
  key_name = var.key_name
  password_hash = var.password_hash
  is_allocate_and_associate_elastic_ip = var.is_allocate_and_associate_elastic_ip
  is_enable_instance_connect = var.is_enable_instance_connect

  // --- Check Point Settings ---
  version_license = var.version_license
}
```


This module creates a CheckPoint TAP Gateway instance in the VPC specified by the user, 
along with a traffic mirror -filter and -target, and two lambda functions: TAP_Lambda and Termination_Lambda.

Once the TAP Gateway instance is deployed, the TAP_Lambda is invoked and scans the entire VPC for 
mirrorable NITRO instances 

<u>**TAP Lambda responsibilities:**</u>
1) Is invoked by Terraform once the TAP Gateway instance is deployed.
Scans the VPC for mirrorable instances and creates traffic mirror sessions between the TAP Gateway's target 
and the instances' eth0 network interface.
2) Is invoked by an EC2 event: every instance in the VPC changes its state to 'Running'.
Checks whether the instance should have a traffic mirror session with the TAP Gateway and acts accordingly: 
Creates a TAP session if one should exist and doesn't, or deletes the existing one if it shouldn't.
3) Is invoked by a scheduled event: every X minutes, configured by the 'schedule_scan_period' variable (default = 10).
Scans the VPC for mirrorable instances and creates/removes traffic mirror sessions between the TAP Gateway's
target and the instances. 

// todo: elaborate on the blacklisting tags map

 <u>**TAP Termination Lambda:**</u>
 
 This Lambda should be manually executed before destroying the Terraform environment.
 An alternative is to navigate to the traffic mirror sessions page and manually delete the relevant sessions.
  
 1) Removes all traffic mirror sessions associated with the TAP Gateway's target
 2) Removes the TAP Gateway's target and filter created upon deployment




## Inputs
| Name          | Description   | Type          | Allowed values | Default       | Required      |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| vpc_id        | The VPC id in which to deploy  | string  | n/a | n/a  | yes |
| external_subnet_id | The external subnet of the security gateway  | string  | n/a | n/a  | yes |
| internal_subnet_id | The internal subnet of the security gateway  | string  | n/a | n/a  | yes |
| resources_tag_name | (Optional) Resources prefix tag  | string  | n/a | ""  | no |
|         |   |   |  |   |  |
| registration_key | The gateway registration key to the TAP cloud (MAC) | string  | n/a | n/a | yes |
| vxlan_ids | (Optional) list of VXLAN IDs (numbers) for mirroring sessions  | list(number)  | n/a | []  | no |
| blacklist_tags |<key,value> map: each pair represents a tag which will blacklist an instance from TAP creation   | map(string)  | n/a | {}  | no |
| schedule_scan_period | (minutes) Lambda will scan the VPC every X minutes for tap status  | number  | n/a | 10  | no |
|         |   |   |  |   |  |
| instance_name | AWS instance name to launch  | string  | n/a | "CP-TAP-Gateway-tf"  | no |
| instance_type | AWS instance type  | string  | n/a | c5.xlarge  | no |
| key_name | The EC2 Key Pair name to allow SSH access to the instances  | string  | n/a | n/a  | yes |
| password_hash | (Optional) Admin user's password hash (use command \"openssl passwd -1 PASSWORD\" to get the PASSWORD's hash)  | string  | n/a | n/a  | yes |
| is_allocate_and_associate_elastic_ip | Associate a public ip address to the instance  | bool  | n/a | true  | no |
| volume_size | Root volume size (GB) - minimum 100  | number  | n/a | 100  | no |
| is_enable_instance_connect | Enable instance connect on instance (R8040+) | bool  | n/a | false  | no |
|         |   |   |  |   |  |
| version_license | Version and license of the Check Point Security Gateway  | string  | - R80.30-BYOL-GW <br/> - R80.30-PAYG-NGTP-GW <br/> - R80.30-PAYG-NGTX-GW <br/> - R80.40-BYOL-GW <br/> - R80.40-PAYG-NGTP-GW <br/> - R80.40-PAYG-NGTX-GW | R80.30-PAYG-NGTP-GW  | no |



## Outputs
| Name  | Description |
| ------------- | ------------- |
| tap-gateway_instance_id  | The instance id of the deployed CheckPoint TAP Gateway  |
| gateway_instance_name  | The instance name of the deployed CheckPoint TAP Gateway  |
| security_group  | The security group id of the deployed CheckPoint TAP Gateway  |
| gateway_instance_public_ip  | The public ip address of the deployed CheckPoint TAP Gateway  |
| traffic_mirror_filter_id  | The traffic mirror filter id created during deployment by the 'tap_target_and_filter' stack  |
| traffic_mirror_target_id  | The traffic mirror target id pointed at the TAP Gateway's internal eni - created during deployment by the 'tap_target_and_filter' stack  |
| tap_lambda_name  | TAP main lambda name (responsible for creating and removing traffic mirror sessions with the TAP Gateway's target)  |
| tap_lambda_description  | TAP main lambda description  |
| termination_lambda_name  | TAP termination lambda name (removes all traffic mirror sessions with the TAP Gateway's target)  |
| termination_lambda_description  | TAP termination lambda description  |

## Authors



## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details
