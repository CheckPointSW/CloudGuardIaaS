# Check Point Gateway Terraform module for AliCloud

Terraform module which deploys a Check Point Security Gateway into an existing VPC.

These types of Terraform resources are supported:
* [Security group](https://www.terraform.io/docs/providers/alicloud/r/security_group.html)
* [Network interface](https://www.terraform.io/docs/providers/alicloud/r/network_interface.html)
* [EIP](https://www.terraform.io/docs/providers/alicloud/r/eip.html) - conditional creation
* [Route_entry](https://www.terraform.io/docs/providers/alicloud/r/route_entry.html) - Internal default route: conditional creation
* [Instance](https://www.terraform.io/docs/providers/alicloud/r/instance.html) - Gateway Instance

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
- Fill all variables in the gateway/**terraform.tfvars** file with proper values (see below for variables descriptions).
- From a command line initialize the Terraform configuration directory:
        terraform init
- Create an execution plan:
        terraform plan
- Create or modify the deployment:
        terraform apply

### terraform.tfvars variables:
| Name                       | Description                                                                                                                                                                                                              | Type   | Allowed values                                                                                                                                                                                                                                | Default                   | Required |
|----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------|----------|
| vpc_id                     | The VPC id in which to deploy                                                                                                                                                                                            | string | n/a                                                                                                                                                                                                                                           | n/a                       | yes      |
| vpc_cidr                   | The CIDR block of the provided VPC                                                                                                                                                                                       | string | n/a                                                                                                                                                                                                                                           | n/a                       | yes      |
| public_vswitch_id          | The public vswitch of the security gateway                                                                                                                                                                               | string | n/a                                                                                                                                                                                                                                           | n/a                       | yes      |
| private_vswitch_id         | The private vswitch of the security gateway                                                                                                                                                                              | string | n/a                                                                                                                                                                                                                                           | n/a                       | yes      |
| private_route_table        | Sets '0.0.0.0/0' route to the Gateway instance in the specified route table (e.g. rtb-12a34567)                                                                                                                          | string | n/a                                                                                                                                                                                                                                           | ""                        | no       |
| gateway_name               | The name tag of the Security Gateway instances (optional)                                                                                                                                                                | string | n/a                                                                                                                                                                                                                                           | "Check-Point-Gateway-tf"  | no       |
| gateway_instance_type      | The instance type of the Security Gateways                                                                                                                                                                               | string | - ecs.g5ne.large <br/> - ecs.g5ne.xlarge <br/> - ecs.g5ne.2xlarge <br/> - ecs.g5ne.4xlarge <br/> - ecs.g5ne.8xlarge <br/> - ecs.g7ne.large <br/> - ecs.g7ne.xlarge <br/> - ecs.g7ne.2xlarge <br/> - ecs.g7ne.4xlarge <br/> - ecs.g7ne.8xlarge | "ecs.g5ne.xlarge"         | no       |
| key_name                   | The ECS Key Pair name to allow SSH access to the instances                                                                                                                                                               | string | n/a                                                                                                                                                                                                                                           | n/a                       | yes      |
| allocate_and_associate_eip | If set to TRUE, an elastic IP will be allocated and associated with the launched instance                                                                                                                                | bool   | true/false                                                                                                                                                                                                                                    | true                      | no       |
| volume_size                | Root volume size (GB) - minimum 100                                                                                                                                                                                      | number | n/a                                                                                                                                                                                                                                           | 100                       | no       |
| disk_category              | The ECS disk category                                                                                                                                                                                                    | string | - cloud <br/> - cloud_efficiency <br/> - cloud_ssd, <br/> - cloud_essd                                                                                                                                                                        | "cloud_efficiency"        | no       |
| ram_role_name              | A predefined RAM role name to attach to the security gateway instance                                                                                                                                                    | string | n/a                                                                                                                                                                                                                                           | ""                        | no       |
| gateway_version            | Gateway version and license                                                                                                                                                                                              | string | - R81-BYOL <br/> - R81.10-BYOL <br/> - R81.20-BYOL                                                                                                                                                                                            | R81-BYOL                  | no       |
| admin_shell                | Set the admin shell to enable advanced command line configuration.                                                                                                                                                       | string | - /etc/cli.sh <br/> - /bin/bash <br/> - /bin/csh <br/> - /bin/tcsh                                                                                                                                                                            | "/etc/cli.sh"             | no       |
| gateway_SIC_Key            | The Secure Internal Communication key for trusted connection between Check Point components. Choose a random string consisting of at least 8 alphanumeric characters                                                     | string | n/a                                                                                                                                                                                                                                           | n/a                       | yes      |
| password_hash              | Admin user's password hash (use command \"openssl passwd -6 PASSWORD\" to get the PASSWORD's hash) (optional)                                                                                                            | string | n/a                                                                                                                                                                                                                                           | ""                        | no       |
| gateway_TokenKey           | (Recommended) Quick connect to Smart-1 Cloud. Paste here the token copied from the Connect Gateway screen in Smart-1 Cloud portal. Follow the instructions in SK180501 to quickly connect this Gateway to Smart-1 Cloud. | string | n/a                                                                                                                                                                                                                                           | ""                        | no       |
| resources_tag_name         | (optional)                                                                                                                                                                                                               | string | n/a                                                                                                                                                                                                                                           | ""                        | no       |
| gateway_hostname           | (optional) The name must not contain reserved words. For details, refer to sk40179.                                                                                                                                      | string | n/a                                                                                                                                                                                                                                           | ""                        | no       |
| allow_upload_download      | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point                                                                                               | bool   | n/a                                                                                                                                                                                                                                           | true                      | no       |
| gateway_bootstrap_script   | (Optional) Semicolon (;) separated commands to run on the initial boot                                                                                                                                                   | string | n/a                                                                                                                                                                                                                                           | ""                        | no       |
| primary_ntp                | (optional)                                                                                                                                                                                                               | string | n/a                                                                                                                                                                                                                                           | "ntp1.cloud.aliyuncs.com" | no       |
| secondary_ntp              | (optional)                                                                                                                                                                                                               | string | n/a                                                                                                                                                                                                                                           | "ntp2.cloud.aliyuncs.com" | no       |

## Example for terraform.tfvars
```
// --- VPC Network Configuration ---
vpc_id = "vpc-"
public_vswitch_id = "vsw-"
private_vswitch_id = "vsw-"
private_route_table = "vtb-"

// --- ECS Instance Configuration ---
gateway_name = "Check-Point-Gateway-tf"
gateway_instance_type = "ecs.g5ne.xlarge"
key_name = "publickey"
allocate_and_associate_eip = true
volume_size = 100
disk_category = "cloud_efficiency"
ram_role_name = ""
instance_tags = {
  key1 = "value1"
  key2 = "value2"
}

// --- Check Point Settings ---
gateway_version = "R81-BYOL"
admin_shell = "/etc/cli.sh"
gateway_SICKey = "12345678"
gateway_password_hash = ""

// --- Quick connect to Smart-1 Cloud (Recommended) ---
gateway_TokenKey = ""

// --- Advanced Settings ---
resources_tag_name = "tag-name"
gateway_hostname = "gw-hostname"
allow_upload_download = true
gateway_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/testfile.txt"
primary_ntp = "ntp1.cloud.aliyuncs.com"
secondary_ntp = "ntp2.cloud.aliyuncs.com"
```
## Conditional creation
- To create an Elastic IP and associate it to the Gateway instance:
```
allocate_and_associate_eip = true
```
- To create a default route at the private route table:
```
private_route_table = "rtb-12345678"
```

## Outputs
| Name                  | Description                                   |
|-----------------------|-----------------------------------------------|
| image_id              | The image id of the deployed Security Gateway |
| permissive_sg_id      | The permissive security group id              |
| permissive_sg_name    | The permissive security group id name         |
| gateway_eip_id        | The id of the elastic IP                      |
| gateway_eip_public_ip | The elastic pubic IP                          |
| gateway_instance_id   | The Security Gateway instance id              |
| gateway_instance_name | The deployed Gateway AliCloud instance name   |

## Revision History

| Template Version | Description                                                                                                                                                                                                        |
|------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 20230615         | - Improved userdata quality and stability by moving to cloud-config<br/>- Define default primary and secondary NTP servers<br/>- Improved deployment experience for gateways and clusters managed by Smart-1 Cloud |
| 20230521         | - Change default shell for the admin user to /etc/cli.sh<br/>- Add description for reserved words in hostname                                                                                                      |
| 20230420         | Change alicloud terraform provider version to 1.203.0                                                                                                                                                              |
| 20230330         | - Added support of ECS disk category. <br/> - Stability fixes.                                                                                                                                                     |
| 20230329         | First release of R81.20 & R81.10 CloudGuard Gateway Terraform deployment in Alibaba Cloud and added support for g7ne instance type.                                                                                |
| 20211011         | First release of Check Point CloudGaurd Gateway Terraform deployment into an existing VPC in Alibaba cloud.                                                                                                        |

## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details