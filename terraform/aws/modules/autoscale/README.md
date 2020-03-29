# Check Point Autoscale Terraform module for AWS

Terrafrom module which deploys an Auto Scaling Group of Check Point Security Gateways into an existing VPC on AWS.

These types of Terraform resources are supported:
* [Launch configuration](https://www.terraform.io/docs/providers/aws/r/launch_configuration.html)
* [Auto Scaling Group](https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html)
* [IAM Role](https://www.terraform.io/docs/providers/aws/r/iam_role.html) - conditional creation
* [Proxy Elastic Load Balancer](https://www.terraform.io/docs/providers/aws/r/elb.html) - conditional creation


See Check Point's documentation for autoscaling group [here](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk112575)

## Usage
Variables are configured in **terraform.tfvars** file as follows:

```
region = "us-east-1"

// --- Environment ---
prefix = "env1"
asg_name = "autoscaling_group"

// --- VPC Network Configuration ---
vpc_id = "vpc-12345678"
subnet_ids = ["subnet-abc123", "subnet-def456"]

// --- Automatic Provisioning with Security Management Server Settings ---
gateways_provision_address_type = "private"
managementServer = "mgmt_env1"
configurationTemplate = "tmpl_env1"

// --- EC2 Instances Configuration ---
instances_name = "asg_gateway"
instance_type = "c5.xlarge"
key_name = "privatekey"

// --- Auto Scaling Configuration ---
minimum_group_size = 2
maximum_group_size = 10
target_groups = ["arn:aws:tg1/abc123", "arn:aws:tg2/def456"]

// --- Check Point Settings ---
version_license = "R80.30-PAYG-NGTP-GW"
admin_shell = "/bin/bash"
password_hash = "12345678"
SICKey = "12345678"
enable_instance_connect = false
allow_upload_download = true
enable_cloudwatch = false
bootstrap_script = "echo 12345678"

// --- Outbound Proxy Configuration (optional) ---
proxy_elb_type = "internet-facing"
proxy_elb_clients = "0.0.0.0/0"
proxy_elb_port = 8080

```
**main.tf**:
```
provider "aws" {
  region = var.region
}

module "autoscale" {
  source = "../../modules/autoscale"

  // --- Environment ---
  prefix = var.prefix
  asg_name = var.asg_name

  // --- VPC Network Configuration ---
  vpc_id = var.vpc_id
  subnet_ids = var.subnet_ids

  // --- Automatic Provisioning with Security Management Server Settings ---
  gateways_provision_address_type = var.gateways_provision_address_type
  managementServer = var.managementServer
  configurationTemplate = var.configurationTemplate

  // --- EC2 Instances Configuration ---
  instances_name = var.instances_name
  instance_type = var.instance_type
  key_name = var.key_name

  // --- Auto Scaling Configuration ---
  minimum_group_size = var.minimum_group_size
  maximum_group_size = var.maximum_group_size
  target_groups = var.target_groups

  // --- Check Point Settings ---
  version_license = var.version_license
  admin_shell = var.admin_shell
  password_hash = var.password_hash
  SICKey = var.SICKey
  enable_instance_connect = var.enable_instance_connect
  allow_upload_download = var.allow_upload_download
  enable_cloudwatch = var.enable_cloudwatch
  bootstrap_script = var.bootstrap_script

  // --- Outbound Proxy Configuration (optional) ---
  proxy_elb_type = var.proxy_elb_type
  proxy_elb_clients = var.proxy_elb_clients
  proxy_elb_port = var.proxy_elb_port
}
```
## Conditional creation
This module creates by default a proxy ELB and does not create an IAM role.
1. To create an ASG configuration with an IAM role:
```
enable_cloudwatch = false
```
2. To create an ASG configuration without a proxy ELB:
```
proxy_elb_type= "none"
```

## Inputs
| Name          | Description   | Type          | Allowed values | Default       | Required      |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| prefix        | (Optional) Instances name prefix  | string  | n/a | ""  | no |
| asg_name  | Autoscaling Group name  | string  | n/a | "CP-ASG-tf"  | no |
|  |  |  |  |  |
| vpc_id | The VPC id in which to deploy | string | n/a | n/a | yes |
| subnet_ids | List of subnet IDs to launch resources into. Recommended at least 2 | list(string) | n/a | n/a | yes |
|  |  |  |  |  |
| gateways_provision_address_type | Determines if the gateways are provisioned using their private or public address.| string | - private <br/> - public | "private" | no |
| managementServer | The name that represents the Security Management Server in the CME configuration | string | n/a | n/a | yes |
| configurationTemplate | Name of the provisioning template in the CME configuration | string  | n/a | n/a | yes |
|  |  |  |  |  |
| instances_name | AWS Name tag of the ASG's instances | string | n/a | "CP-ASG-gateway-tf" | no |
| instance_type | AWS instance type. | string | - c5.large <br/> - c5.xlarge <br/> - c5.2xlarge <br/> - c5.4xlarge <br/> - c5.9xlarge <br/> - c5.18xlarge | "c5.xlarge" | no |
| key_name | The EC2 Key Pair name to allow SSH access to the instances | string  | n/a | n/a | yes |
|  |  |  |  |  |
| minimum_group_size | The minimum number of instances in the Auto Scaling group | number | n/a | 2 | no |
| maximum_group_size | The maximum number of instances in the Auto Scaling group | number | n/a | 10 | no |
| target_groups | (Optional) List of Target Group ARNs to associate with the Auto Scaling group | list(string) | n/a | [] | no |
|  |  |  |  |  |
| version_license | Version and license of the Check Point Security Gateways. | string | - R80.30-BYOL-GW <br/> - R80.30-PAYG-NGTP-GW <br/> - R80.30-PAYG-NGTX-GW <br/> - R80.40-BYOL-GW <br/> - R80.40-PAYG-NGTP-GW <br/> - R80.40-PAYG-NGTX-GW | "R80.30-PAYG-NGTP-GW" | no |
| admin_shell | Set the admin shell to enable advanced command line configuration. | string | - /etc/cli.sh <br/> - /bin/bash <br/> - /bin/csh <br/> - /bin/tcsh | "/etc/cli.sh" | no |
| password_hash | (Optional) Admin user's password hash (use command \"openssl passwd -1 PASSWORD\" to get the PASSWORD's hash) | string | n/a | "" | no |
| SICKey | The Secure Internal Communication key for trusted connection between Check Point components (at least 8 alphanumeric characters) | string | n/a | n/a | yes |
| enable_instance_connect | Enable AWS Instance Connect - not supported with versions prior to R80.40 | bool | true/false | false | no |
| allow_upload_download | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point | bool | n/a | true | no |
| enable_cloudwatch | Report Check Point specific CloudWatch metrics | bool | true/false | false | no |
| bootstrap_script | (Optional) Semicolon (;) separated commands to run on the initial boot | string | n/a | "" | no |
|  |  |  |  |  |
| proxy_elb_type | Type of ELB to create as an HTTP/HTTPS outbound proxy. | string | - none <br/> - internal <br/> - internet-facing | "none" | no |
| proxy_elb_port | The TCP port on which the proxy will be listening | number | n/a | 8080 | no |
| proxy_elb_clients | The CIDR range of the clients of the proxy | string | n/a | "0.0.0.0/0" | no |


## Outputs
| Name  | Description |
| ------------- | ------------- |
| autoscale-autoscaling_group_id  | The id of the deployed AutoScaling Group  |
| autoscale-autoscaling_group_name  | The name of the deployed AutoScaling Group  |
| autoscale-autoscaling_group_arn  | The ARN for the deployed AutoScaling Group  |
| autoscale-autoscaling_group_availability_zones  | The AZs on which the Autoscaling Group is configured  |
| autoscale-autoscaling_group_desired_capacity  | The deployed AutoScaling Group's desired capacity of instances |
| autoscale-autoscaling_group_min_size  | The deployed AutoScaling Group's minimum number of instances  |
| autoscale-autoscaling_group_max_size  | The deployed AutoScaling Group's maximum number  of instances  |
| autoscale-autoscaling_group_load_balancers  | The deployed AutoScaling Group's configured load balancers  |
| autoscale-autoscaling_group_target_group_arns  | The deployed AutoScaling Group's configured target groups  |
| autoscale-autoscaling_group_subnets  | The subnets on which the deployed AutoScaling Group is configured |
| autoscale-launch_configuration_id  | The id of the Launch Configuration  |
| autoscale-security_group  | The deployed AutoScaling Group's security group id  |
| autoscale-iam_role_name  | The deployed AutoScaling Group's IAM role name (if created)  |

## Authors



## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details
