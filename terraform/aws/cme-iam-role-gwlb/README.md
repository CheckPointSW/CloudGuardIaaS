# AWS IAM Role for Cloud Management Extension (CME) manages Gateway Load Balancer Auto Scale Group Terraform module

Terraform module which creates an AWS IAM Role for Cloud Management Extension (CME) manages Gateway Load Balancer Auto Scale Group on Security Management Server.

These types of Terraform resources are supported:
* [AWS IAM role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)
* [AWS IAM policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)
* [AWS IAM policy attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)

This type of Terraform data source is supported:
* [AWS IAM policy document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)

See the [Creating an AWS IAM Role for Security Management Server](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk122074) for additional information

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
- Static credentials can be provided by adding an access_key and secret_key in /terraform/aws/cme-iam-role-gwlb/**terraform.tfvars** file as follows:
```
region     = "us-east-1"
access_key = "my-access-key"
secret_key = "my-secret-key"
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
  
## Usage
- Fill all variables in the /terraform/aws/cme-iam-role-gwlb/**terraform.tfvars** file with proper values (see below for variables descriptions).
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

- Variables are configured in /terraform/aws/cme-iam-role-gwlb/**terraform.tfvars** file as follows:

  ```
    //PLEASE refer to README.md for accepted values FOR THE VARIABLES BELOW

    permissions = "Create with read permissions"
    sts_roles = ['arn:aws:iam::111111111111:role/role_name']
    trusted_account = ""
  ```

- To tear down your resources:
    ```
    terraform destroy
    ```


## Inputs
| Name            | Description                                                                                                                                                           | Type         | Allowed values                                                                                                                                  | Default                      | Required |
|-----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------|-------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------|----------|
| permissions     | The IAM role permissions                                                                                                                                              | string       | - Create with assume role permissions (specify an STS role ARN) <br/> - Create with read permissions <br/> - Create with read-write permissions | Create with read permissions | no       |
| sts_roles       | The IAM role will be able to assume these STS Roles (map of string ARNs)                                                                                              | list(string) | n/a                                                                                                                                             | []                           | no       |
| trusted_account | A 12 digits number that represents the ID of a trusted account. IAM users in this account will be able assume the IAM role and receive the permissions attached to it | string       | n/a                                                                                                                                             | ""                           | no       |


## Outputs
| Name                 | Description                           |
|----------------------|---------------------------------------|
| cme_iam_role_arn     | The created AWS IAM Role arn          |
| cme_iam_role_name    | The created AWS IAM Role name         |
| cme_iam_profile_name | The created AWS instance profile name |
| cme_iam_profile_arn  | The created AWS instance profile arn  |

## Revision History
In order to check the template version, please refer to [sk116585](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk116585)

| Template Version | Description                                                        |
|------------------|--------------------------------------------------------------------|
| 20240507         | Add ec2:DescribeRegions read permission to the IAM role policy     |
| 20231012         | Update AWS Terraform provider version to 5.20.1                    |
| 20230926         | CME instance profile for IAM Role                                  |

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details
