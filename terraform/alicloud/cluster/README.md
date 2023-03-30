# Check Point CloudGuard Network Security Cluster Terraform module for AliCloud

Terraform module which deploys a Check Point CloudGuard Network Security Cluster into an existing VPC.

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
- Fill all variables in the cluster/**terraform.tfvars** file with proper values (see below for variables descriptions).
- From a command line initialize the Terraform configuration directory:
        terraform init
- Create an execution plan:
        terraform plan
- Create or modify the deployment:
        terraform apply

### terraform.tfvars variables:
| Name                       | Description                                                                                                                                                                                                                                                                                               | Type        | Allowed values                                                                                                                                                                                                                                | Default                  | Required |
|----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------|----------|
| vpc_id                     | The VPC id in which to deploy                                                                                                                                                                                                                                                                             | string      | n/a                                                                                                                                                                                                                                           | n/a                      | yes      |
| cluster_vswitch_id         | The cluster vswitch of the security gateways                                                                                                                                                                                                                                                              | string      | Subnet in the same availability zone with mgmt_vswitch_id and private_vswitch_id                                                                                                                                                              | n/a                      | yes      |
| mgmt_vswitch_id            | The management vswitch of the security gateways Connect the Security Gateways to the Management Server with the ENI in this vswitch.                                                                                                                                                                      | string      | Subnet in the same availability zone with cluster_vswitch_id and private_vswitch_id                                                                                                                                                           | n/a                      | yes      |
| private_vswitch_id         | The private vswitch of the security gateways                                                                                                                                                                                                                                                              | string      | Subnet in the same availability zone with cluster_vswitch_id and mgmt_vswitch_id                                                                                                                                                              | n/a                      | yes      |
| private_route_table        | (optional) Sets '0.0.0.0/0' route to the Active Cluster member instance in the specified route table (e.g. vtb-12a34567). Route table cannot have an existing 0.0.0.0/0 route. If empty - traffic will not be routed through the Security Gateway, this requires manual configuration in the Route Table. | string      | n/a                                                                                                                                                                                                                                           | ""                       | no       |
| gateway_name               | (optional) The name tag of the Cluster's Security Gateway instances                                                                                                                                                                                                                                       | string      | n/a                                                                                                                                                                                                                                           | "Check-Point-Cluster-tf" | no       |
| gateway_instance_type      | The instance type of the Security Gateways                                                                                                                                                                                                                                                                | string      | - ecs.g5ne.large <br/> - ecs.g5ne.xlarge <br/> - ecs.g5ne.2xlarge <br/> - ecs.g5ne.4xlarge <br/> - ecs.g5ne.8xlarge <br/> - ecs.g7ne.large <br/> - ecs.g7ne.xlarge <br/> - ecs.g7ne.2xlarge <br/> - ecs.g7ne.4xlarge <br/> - ecs.g7ne.8xlarge | "ecs.g5ne.xlarge"        | no       |
| key_name                   | The ECS Key Pair name to allow SSH access to the instances                                                                                                                                                                                                                                                | string      | n/a                                                                                                                                                                                                                                           | n/a                      | yes      |
| allocate_and_associate_eip | If set to TRUE, an elastic IP will be allocated and associated with each cluster member, in addition to the cluster Elastic IP                                                                                                                                                                            | bool        | true/false                                                                                                                                                                                                                                    | true                     | no       |
| volume_size                | Root volume size (GB) - minimum 100                                                                                                                                                                                                                                                                       | number      | n/a                                                                                                                                                                                                                                           | 100                      | no       |
| disk_category              | The ECS disk category                                                                                                                                                                                                                                                                                     | string      | - cloud <br/> - cloud_efficiency <br/> - cloud_ssd, <br/> - cloud_essd                                                                                                                                                                        | "cloud_efficiency"       | no       |
| ram_role_name              | A predefined RAM role name to attach to the cluster's security gateway instances                                                                                                                                                                                                                          | string      | n/a                                                                                                                                                                                                                                           | ""                       | no       |
| instance_tags              | (Optional) A map of tags as key=value pairs. All tags will be added to the Gateway ECS Instances                                                                                                                                                                                                          | map(string) | n/a                                                                                                                                                                                                                                           | {}}                      | no       |
| gateway_version            | Gateway version and license                                                                                                                                                                                                                                                                               | string      | - R81-BYOL <br/> - R81.10-BYOL <br/> - R81.20-BYOL                                                                                                                                                                                            | R81-BYOL                 | no       |
| admin_shell                | Set the admin shell to enable advanced command line configuration.                                                                                                                                                                                                                                        | string      | - /etc/cli.sh <br/> - /bin/bash <br/> - /bin/csh <br/> - /bin/tcsh                                                                                                                                                                            | "/etc/cli.sh"            | no       |
| gateway_SIC_Key            | The Secure Internal Communication key for trusted connection between Check Point components. Choose a random string consisting of at least 8 alphanumeric characters                                                                                                                                      | string      | n/a                                                                                                                                                                                                                                           | n/a                      | yes      |
| gateway_password_hash      | (optional) Admin user's password hash (use command \"openssl passwd -6 PASSWORD\" to get the PASSWORD's hash)                                                                                                                                                                                             | string      | n/a                                                                                                                                                                                                                                           | ""                       | no       |
| management_ip_address      | (Optional) The Security Management IP address (public or private IP address). If provided, a static-route [management_ip --> via eth1] will be added to the Cluster's Security Gateway instances. If not provided, the static-route will need to be added manually post-deployment by user                | string      | n/a                                                                                                                                                                                                                                           | ""                       | no       |
| resources_tag_name         | (optional) Name tag prefix of the resources                                                                                                                                                                                                                                                               | string      | n/a                                                                                                                                                                                                                                           | ""                       | no       |
| gateway_hostname           | (optional) The host name will be appended with member-a/b accordingly                                                                                                                                                                                                                                     | string      | n/a                                                                                                                                                                                                                                           | ""                       | no       |
| allow_upload_download      | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point                                                                                                                                                                                | bool        | n/a                                                                                                                                                                                                                                           | true                     | no       |
| gateway_bootstrap_script   | (Optional) Semicolon (;) separated commands to run on the initial boot                                                                                                                                                                                                                                    | string      | n/a                                                                                                                                                                                                                                           | ""                       | no       |
| primary_ntp                | (optional)                                                                                                                                                                                                                                                                                                | string      | n/a                                                                                                                                                                                                                                           | ""                       | no       |
| secondary_ntp              | (optional)                                                                                                                                                                                                                                                                                                | string      | n/a                                                                                                                                                                                                                                           | ""                       | no       |

## Example for terraform.tfvars
```
// --- VPC Network Configuration ---
vpc_id = "vpc-12345678"
cluster_vswitch_id = "vsw-01234"
mgmt_vswitch_id = "vsw-34567"
private_vswitch_id = "vsw-56789"
private_route_table = "vtb-12345678"

// --- ECS Instance Configuration ---
gateway_name = "Check-Point-Cluster-tf"
gateway_instance_type = "ecs.g5ne.xlarge"
key_name = "privatekey"
allocate_and_associate_eip = true
volume_size = 100
disk_category = "cloud_efficiency"
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
- To create a default route to the Active Cluster member, fill the private_route_table variable:
```
private_route_table = "rtb-12345678"
```
- To create a cluster RAM role for your Cluster instances with the required permissions for Cluster behavior, leave the ram_role_name variable empty:
```
ram_role_name = ""
```

## Outputs
| Name                   | Description                                    |
|------------------------|------------------------------------------------|
| cluster_primary_EIP    | Cluster Primary EIP                            |
| cluster_secondary_EIP  | Cluster secondary EIP                          |
| image_id               | The image id of the deployed Security Gateways |
| member_a_EIP           | Member A instance EIP                          |
| member_b_EIP           | Member B instance EIP                          |
| member_a_instance_id   | Member A instance id                           |
| member_b_instance_id   | Member B instance id                           |
| member_a_instance_name | Member A instance name                         |
| member_b_instance_name | Member B instance name                         |
| permissive_sg_id       | The permissive security group id               |
| permissive_sg_name     | The permissive security group name             |

## Revision History

| Template Version | Description                                                                                                                         |
|------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| 20230330         | - Added support of ECS disk category. <br/> - Stability fixes.                                                                      |
| 20230329         | First release of R81.20 & R81.10 CloudGuard Gateway Terraform deployment in Alibaba Cloud and added support for g7ne instance type. |           
| 20211011         | First release of Check Point CloudGuard Cluster Terraform deployment into an existing VPC in Alibaba cloud.                         |


## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details
