# AWS CloudFormation Templates

[CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html) is an Amazon Web Services (AWS) service that enables modeling and setting up resources inside AWS in an automated fashion.


The table below lists CloudFormation templates provided and maintained by Check Point that simplify the deployment of Check Point security solutions in AWS.  

You can use these templates as-is or as building blocks for customizing your own templates.

**Notes:**

* You must accept the Software Terms of the relevant Check Point Product AMI in the [AWS Marketplace](https://aws.amazon.com/marketplace/) at least once prior to launching the CloudFormation templates. It is not required to actually launch the instance from the Marketplace, but the agreement must be accepted from this location.

* Some stacks may "roll back" automatically after 1 hour, with an error "WaitCondition timed out" If this happens, please check Internet access is working, either through AWS (Internet Gateway (IGW) assigned to the VPC, routetables with a default route and assigned to the relevant subnet(s), and Elastic IP (EIP) assigned, etc), or through another method like external proxy, or route to on-prem, for example. 


# Manual Deployment
In case you want to deploy a custom template that is not listed follow this steps:
## 1. Login to AWS Console
## 2. Navigate to CloudFormation service
## 3. Click on "Create stack" button.
When in the CloudFormation service, click on "Create stack" button and then select "With new resources (standard)".  
![Step 1](../../images/step1_aws.png)

## 4. Upload desired template
Use this menu to upload your custom template (yaml/json file)
![Step 2](../../images/step2_aws.png)
After the file is uploaded, click next.

## 5. Enter the desired template's parameters

## 6. Configure stack options

## 7. Review and create stack.



