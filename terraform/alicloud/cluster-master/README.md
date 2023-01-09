# Check Point CloudGuard Network Security Cluster Master Terraform module for AliCloud

Terraform module which deploys a Check Point CloudGuard Network Security Cluster into a new VPC.

These types of Terraform resources are supported:
* [Security group](https://www.terraform.io/docs/providers/alicloud/r/security_group.html)
* [Network interface](https://www.terraform.io/docs/providers/alicloud/r/network_interface.html)
* [EIP](https://www.terraform.io/docs/providers/alicloud/r/eip.html) - conditional creation
* [Route_entry](https://www.terraform.io/docs/providers/alicloud/r/route_entry.html) - Internal default route: conditional creation
* [Instance](https://www.terraform.io/docs/providers/alicloud/r/instance.html) - Gateway Instances
* [RAM Role](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_role)

## Note
- Make sure your region and zone are supporting the gateway instance types in **modules/common/instance_type/main.tf**
  [Alicloud Instance_By_Region](https://ecs-buy.aliyun.com/instanceTypes/?spm=a2c63.p38356.879954.139.1eeb2d44eZQw2m#/instanceTypeByRegion)
  
## Configuration

- Due to a terraform limitation, apply command is:
```
terraform apply -target=alicloud_route_table.private_vswitch_rt -auto-approve && terraform apply 
```
>Once terraform is updated, we will update accordingly.

- Best practice is to configure credentials in the Environment variables - [Alicloud provider](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)
```
Configure environment variables in Linux:

$ export ALICLOUD_ACCESS_KEY=anaccesskey
$ export ALICLOUD_SECRET_KEY=asecretkey
$ export ALICLOUD_REGION=cn-beijing

Configure envrionment variables in Windows:
  set ALICLOUD_ACCESS_KEY=anaccesskey
  set ALICLOUD_SECRET_KEY=asecretkey
  set ALICLOUD_REGION=cn-beijing

```

## Usage
- Fill all variables in the cluster-master/**terraform.tfvars** file with proper values (see below for variables descriptions).
- From a command line initialize the Terraform configuration directory:
        terraform init
- Create an execution plan:
        terraform plan -target=alicloud_route_table.private_vswitch_rt -auto-approve && terraform plan
- Create or modify the deployment:
        terraform apply -target=alicloud_route_table.private_vswitch_rt -auto-approve && terraform apply

### terraform.tfvars variables:

| Name          | Description   | Type          | Allowed values | Default       | Required      |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| vpc_cidr | The CIDR block of the VPC | string | n/a | n/a | yes |
| cluster_vswitchs_map | A map of pairs {availability-zone = vswitch-suffix-number}. Each entry creates a vswitch. Minimum 1 pair.  (e.g. {\"us-east-1a\" = 1} ) | map | n/a |  n/a | yes |
| management_vswitchs_map | A map of pairs {availability-zone = vswitch-suffix-number}. Each entry creates a vswitch. Minimum 1 pair.  (e.g. {\"us-east-1a\" = 1} ) | map | n/a |  n/a | yes |
| private_vswitchs_map | A map of pairs {availability-zone = vswitch-suffix-number}. Each entry creates a vswitch. Minimum 1 pair. (e.g. {\"us-east-1a\" = 2} ) | map | n/a | n/a | yes |
| vswitchs_bit_length | Number of additional bits with which to extend the vpc cidr. For example, if given a vpc_cidr ending in /16 and a vswitchs_bit_length value of 4, the resulting vswitch address will have length /20. | number | n/a | n/a | yes |
| gateway_name | (optional) The name tag of the Cluster's Security Gateway instances | string | n/a | "Check-Point-Cluster-tf" | no |
| gateway_instance_type | The instance type of the Security Gateways | string | - ecs.g5ne.large <br/> - ecs.g5ne.xlarge <br/> - ecs.g5ne.2xlarge <br/> - ecs.g5ne.4xlarge <br/> - ecs.g5ne.8xlarge  | "ecs.g5ne.xlarge" | no |
| key_name | The ECS Key Pair name to allow SSH access to the instances | string  | n/a | n/a | yes |
| allocate_and_associate_eip | If set to TRUE, an elastic IP will be allocated and associated with each cluster member, in addition to the cluster Elastic IP | bool | true/false | true | no |
| volume_size | Root volume size (GB) - minimum 100 | number | n/a | 100 | no |
| ram_role_name | A predefined RAM role name to attach to the cluster's security gateway instances | string | n/a | "" | no |
| instance_tags | (Optional) A map of tags as key=value pairs. All tags will be added to the Gateway ECS Instances | map(string) | n/a | {}} | no |
| gateway_version | Gateway version and license | string | - R81-BYOL | R81-BYOL | no |
| admin_shell | Set the admin shell to enable advanced command line configuration. | string | - /etc/cli.sh <br/> - /bin/bash <br/> - /bin/csh <br/> - /bin/tcsh | "/etc/cli.sh" | no |
| gateway_SIC_Key | The Secure Internal Communication key for trusted connection between Check Point components. Choose a random string consisting of at least 8 alphanumeric characters | string | n/a | n/a | yes |
| gateway_password_hash | (optional) Admin user's password hash (use command \"openssl passwd -6 PASSWORD\" to get the PASSWORD's hash) | string | n/a | "" | no |
| management_ip_address | (Optional) The Security Management IP address (public or private IP address). If provided, a static-route [management_ip --> via eth1] will be added to the Cluster's Security Gateway instances. If not provided, the static-route will need to be added manually post-deployment by user | string | n/a | "" | no |
| resources_tag_name | (optional) Name tag prefix of the resources | string | n/a | "" | no |
| gateway_hostname | (optional) The host name will be appended with member-a/b accordingly | string | n/a | "" | no |
| allow_upload_download | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point | bool | n/a | true | no |
| gateway_bootstrap_script | (Optional) Semicolon (;) separated commands to run on the initial boot | string | n/a | "" | no |
| primary_ntp | (optional) | string | n/a | "" | no |
| secondary_ntp | (optional) | string | n/a | "" | no |

## Example for terraform.tfvars

```
// --- VPC Network Configuration ---
vpc_cidr = "10.0.0.0/16"
cluster_vswitchs_map = {
  "us-east-1a" = 1
}
management_vswitchs_map = {
  "us-east-1a" = 2
}
private_vswitchs_map = {
  "us-east-1a" = 3
}
vswitchs_bit_length = 8

// --- ECS Instance Configuration ---
gateway_name = "Check-Point-Cluster-tf"
gateway_instance_type = "ecs.g5ne.xlarge"
key_name = "privatekey"
allocate_and_associate_eip = true
volume_size = 100
ram_role_name = "role_name"
instance_tags = {
  key1 = "value1"
  key2 = "value2"
}

// --- Check Point Settings ---
gateway_version = "R81-BYOL"
admin_shell = "/bin/bash"
gateway_SICKey = "12345678"
gateway_password_hash = "12345678"

// --- Advanced Settings ---
resources_tag_name = "tag-name"
gateway_hostname = "gw-hostname"
allow_upload_download = true
gateway_bootstrap_script = "echo 12345678"
primary_ntp = "123.456.789.123"
secondary_ntp = "abc.def.ghi.jkl"

```
## Conditional creation
- To create an Elastic IP for each Cluster member and associate it to the Security Gateway instances:
```
allocate_and_associate_eip = true
```

## Outputs
| Name  | Description |
| ------------- | ------------- |
| vpc_id  | The id of the deployed vpc  |
| internal_rt_id  | The internal route table id id  |
| vpc_cluster_vswitchs_ids_list  | A list of the cluster vswitchs ids  |
| vpc_management_vswitchs_ids_list  | A list of the management vswitchs ids  |
| vpc_private_vswitchs_ids_list  | A list of the private vswitchs ids  |
| image_id  | The image id of the deployed Security Gateways  |
| cluster_primary_EIP  | Cluster Primary EIP |
| cluster_secondary_EIP  | Cluster secondary EIP |
| member_a_EIP  | Member A instance EIP |
| member_b_EIP  | Member B instance EIP |
| member_a_instance_id  | Member A instance id |
| member_b_instance_id  | Member B instance id |
| member_a_instance_name  | Member A instance name |
| member_b_instance_name  | Member B instance name |
| permissive_sg_id  | The permissive security group id  |
| permissive_sg_name  | The permissive security group name |

## Revision History

| Template Version | Description   |
| ---------------- | ------------- |
| 20211011 | First release of Check Point CloudGuard Cluster Terraform deployment into a new VPC in Alibaba cloud. |
| | | |

## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details
