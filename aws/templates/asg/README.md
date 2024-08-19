
## Security Gateway Auto Scaling
<table>
    <thead>
        <tr>
            <th>Description</th>
            <th>Notes</th>
            <th>Direct Launch</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td width="40%">
           Deploys and configures the Security Gateways as an AWS Auto Scaling group. <br/><br/> For more details, refer to the <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CloudGuard_Network_for_AWS_AutoScaling_DeploymentGuide/Default.htm" >CloudGuard Network Auto Scaling for AWS R80.20 and Higher Deployment Guide </a>. 
            </td>
            <td width="40%">Deploys an Auto Scaling group of Security Gateways into an existing VPC.</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/autoscale/autoscale.yaml&stackName=Check-Point-Security-Gateway-AutoScaling"><img src="../../images/launch.png"/></a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Revision History
In order to check the template version, please refer to [sk125252](https://support.checkpoint.com/results/sk/sk125252#ToggleR8120gateway)

| Template Version | Description                                                                                                                          |
|------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| 20240704         | - R80.40 version deprecation.<br/>- R81 version deprecation.                                                                         |
| 20240519         | Add support for requiring use instance metadata service version 2 (IMDSv2) only                                                      |
| 20240414         | Add support for Elastic Load Balancer Health Checks.                                                                                 |
| 20240131         | Network Load Balancer Health Check configuration change for higher than R81 version. New Health Check Port is 8117 and Protocol TCP. |
| 20230923         | Add support for C5d instance type.                                                                                                   |
| 20230521         | Change default Check Point version to R81.20                                                                                         |
| 20230521         | Change default shell for the admin user to /etc/cli.sh                                                                               |
| 20221226         | Support ASG Launch Template instead of Launch Configuration                                                                          |
| 20221123         | Templates version 20221123 and above support R81.20                                                                                  |
| 20220606         | New instance type support.                                                                                                           |
| 20210329         | Stability fixes                                                                                                                      |
| 20210309         | AWS Terraform modules refactor                                                                                                       |
| 20200318         | First release of Check Point Auto Scaling Terraform module for AWS                                                                   |
