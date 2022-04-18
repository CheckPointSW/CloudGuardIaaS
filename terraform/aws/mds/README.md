# Check Point CloudGuard Network Multi-Domain Server Terraform module for AWS

Terraform module which deploys a Check Point CloudGuard Network Multi-Domain Server into an existing VPC.

These types of Terraform resources are supported:
* [AWS Instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
* [Security Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
* [Network interface](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface)
* [IAM Role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) - conditional creation

See the [Multi-Domain Management Deployment on AWS](https://supportcenter.us.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk143213) for additional information

This solution uses the following modules:
- /terraform/aws/modules/amis
- /terraform/aws/cme-iam-role

## Configurations

The **main.tf** file includes the following provider configuration block used to configure the credentials for the authentication with AWS, as well as a default region for your resources:
```
provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
```
The provider credentials can be provided either as static credentials or as [Environment Variables](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables).
- Static credentials can be provided by adding an access_key and secret_key in /terraform/aws/mds/**terraform.tfvars** file as follows:
```
region     = "us-east-1"
access_key = "my-access-key"
secret_key = "my-secret-key"
```
- In case the Static credentials are used, perform modifications described below:<br/>
  a. The next lines in main.tf file, in the provider aws resource, need to be commented for sub-module /terraform/aws/cme-iam-role:
  ```
  provider "aws" {
  //  region = var.region
  //  access_key = var.access_key
  //  secret_key = var.secret_key
  }
  ```
- In case the Environment Variables are used, perform modifications described below:<br/>
  a. The next lines in main.tf file, in the provider aws resource, need to be commented:
  ```
  provider "aws" {
  //  region = var.region
  //  access_key = var.access_key
  //  secret_key = var.secret_key
  }
  ```
  b. The next lines in main.tf file, in the provider aws resource, need to be commented for sub-module /terraform/aws/cme-iam-role:
  ```
  provider "aws" {
  //  region = var.region
  //  access_key = var.access_key
  //  secret_key = var.secret_key
  }
  ```

## Usage
- Fill all variables in the /terraform/aws/mds/**terraform.tfvars** file with proper values (see below for variables descriptions).
- From a command line initialize the Terraform configuration directory:
    ```
    terraform init
    ```
- Create an execution plan:
    ```
    terraform plan
    ```
- Create or modify the deployment:
    ```
    terraform apply
    ```
  
- Variables are configured in /terraform/aws/mds/**terraform.tfvars** file as follows:

  ```
  //PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW
  
  // --- VPC Network Configuration ---
  vpc_id = "vpc-12345678"
  subnet_id = "subnet-abc123"
  
  // --- EC2 Instances Configuration ---
  mds_name = "CP-MDS-tf"
  mds_instance_type = "m5.12xlarge"
  key_name = "privatekey"
  volume_size = 100
  volume_encryption = "alias/aws/ebs"
  enable_instance_connect = false
  instance_tags = {
    key1 = "value1"
    key2 = "value2"
  }
  
  // --- IAM Permissions ---
  iam_permissions = "Create with read permissions"
  predefined_role = ""
  sts_roles = []
  
  // --- Check Point Settings ---
  mds_version = "R81-BYOL"
  mds_admin_shell = "/bin/bash"
  mds_password_hash = "12345678"
  
  // --- Multi-Domain Server Settings ---
  mds_hostname = "mds-tf"
  mds_SICKey = ""
  allow_upload_download = "true"
  mds_installation_type = "Primary Multi-Domain Server"
  admin_cidr = "0.0.0.0/0"
  gateway_addresses = "0.0.0.0/0"
  primary_ntp = ""
  secondary_ntp = ""
  mds_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/testfile.txt"
  ```

- Conditional creation
  - To create IAM Role:
  ```
  iam_permissions = "Create with read permissions" | "Create with read-write permissions" | "Create with assume role permissions (specify an STS role ARN)"
  and
  mds_installation_type = "Primary Multi-Domain Server"
  ```
- To tear down your resources:
    ```
    terraform destroy
    ```

## Inputs
| Name          | Description   | Type          | Allowed values | Default       | Required      |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| vpc_id        | The VPC id in which to deploy | string    | n/a   | n/a   | yes |
| subnet_id     | To access the instance from the internet, make sure the subnet has a route to the internet | string    | n/a   | n/a   | yes  |
| mds_name | (Optional) The name tag of the Multi-Domain Server instance   | string    | n/a   | Check-Point-MDS-tf  | no  |
| mds_instance_type | The instance type of the Multi-Domain Server  | string  | - m5.4xlarge <br/> - m5.12xlarge <br/> - m5.24xlarge | m5.12xlarge  | no  |
| key_name | The EC2 Key Pair name to allow SSH access to the instance | string  | n/a | n/a | yes |
| volume_size  | Root volume size (GB) - minimum 100  | number  | n/a  | 100  | no  |
| volume_encryption  | KMS or CMK key Identifier: Use key ID, alias or ARN. Key alias should be prefixed with 'alias/' (e.g. for KMS default alias 'aws/ebs' - insert 'alias/aws/ebs')  | string  | n/a  | alias/aws/ebs  | no  |
| enable_instance_connect  | Enable SSH connection over AWS web console. Supporting regions can be found [here](https://aws.amazon.com/about-aws/whats-new/2019/06/introducing-amazon-ec2-instance-connect/)  | bool  | true/false  | false  | no  |
| instance_tags  | (Optional)  A map of tags as key=value pairs. All tags will be added to the Multi-Domain Server EC2 Instance  | map(string)  | n/a  | {}  | no  |
| iam_permissions  | IAM role to attach to the instance profile  | string  | - None (configure later) <br/> - Use existing (specify an existing IAM role name) <br/> - Create with assume role permissions (specify an STS role ARN) <br/> - Create with read permissions <br/> - Create with read-write permissions  | Create with read permissions  | no  |
| predefined_role  | (Optional) A predefined IAM role to attach to the instance profile. Ignored if var.iam_permissions is not set to 'Use existing'  | string  | n/a  | ""  | no  |
| sts_roles  | (Optional) The IAM role will be able to assume these STS Roles (list of ARNs). Ignored if var.iam_permissions is set to 'None' or 'Use existing'  | list(string)  | n/a  | []  | no  |
| mds_version  | Multi-Domain Server version and license  | string  | - R80.40-BYOL <br/> - R81-BYOL <br/> - R81.10-BYOL | R81-BYOL  | no  |
| mds_admin_shell  | Set the admin shell to enable advanced command line configuration  | string  | - /etc/cli.sh <br/> - /bin/bash <br/> - /bin/csh <br/> - /bin/tcsh | /etc/cli.sh | no |
| mds_password_hash | (Optional) Admin user's password hash (use command "openssl passwd -6 PASSWORD" to get the PASSWORD's hash) | string | n/a | "" | no |
| mds_hostname  | (Optional) Multi-Domain Server prompt hostname  | string  | n/a  | ""  | no  |
| mds_SICKey  | Mandatory if deploying a Secondary Multi-Domain Server or Multi-Domain Log Server, the Secure Internal Communication key creates trusted connections between Check Point components. Choose a random string consisting of at least 8 alphanumeric characters  | string  | n/a  | ""  | no  |
| allow_upload_download | Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point | bool | true/false | true | no |
| mds_installation_type  | Determines the Multi-Domain Server installation type  | string  | - Primary Multi-Domain Server <br/> - Secondary Multi-Domain Server  <br/> - Multi-Domain Log Server | Primary Multi-Domain Server  | no  |
| admin_cidr  | (CIDR) Allow web, ssh, and graphical clients only from this network to communicate with the Multi-Domain Server  | string  | valid CIDR  | 0.0.0.0/0  | no  |
| gateway_addresses  | (CIDR) Allow gateways only from this network to communicate with the Multi-Domain Server  | string  | valid CIDR  | 0.0.0.0/0  | no  |
| primary_ntp  | (Optional) The IPv4 addresses of Network Time Protocol primary server | string  | n/a  | 169.254.169.123  | no  |
| secondary_ntp  | (Optional) The IPv4 addresses of Network Time Protocol secondary server  | string  | n/a  | 0.pool.ntp.org  | no  |
| mds_bootstrap_script | (Optional) Semicolon (;) separated commands to run on the initial boot | string | n/a | "" | no |


## Outputs
| Name  | Description |
| ------------- | ------------- |
| mds_instance_id  | The deployed Multi-Domain Server AWS instance id  |
| mds_instance_name  | The deployed Multi-Domain Server AWS instance name  |
| mds_instance_tags  | The deployed Multi-Domain Server AWS tags  |

## Revision History
In order to check the template version, please refer to [sk116585](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk116585)

| Template Version | Description   |
| ---------------- | ------------- |
| 20210309 | First release of Check Point Multi-Domain Server Terraform module for AWS |
| 20210329 | Stability fixes |



## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details
