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

| Template Version | Description                                                                                                                         |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| 20260316         | Added Diagnostics.                                                                                             |
| 20260310         | Added IPv6 support via IPMode variable.                                                                                             |
| 20260101         | Templates version 20260101 and higher support R82.10                                                                                |
| 20250826         | Changed the default solution version to R82-BYOL                                                                                    |
| 20250821         | Added new Auto Scale Group and Management templates for deployments with new VPC                                                    |
| 20241225         | Add references to Administration Guides in the description of templates                                                             |
| 20241204         | Add support for instance types C7i, M7a, R7a                                                                                        |
| 20241027         | Templates version 20241027 and higher support R82                                                                                   |
| 20240519         | Add support for requiring use instance metadata service version 2 (IMDSv2) only                                                     |
| 20240414         | Add support for Elastic Load Balancer Health Checks                                                                                 |
| 20240131         | Network Load Balancer Health Check configuration change for higher than R81 version. New Health Check Port is 8117 and Protocol TCP |
| 20230923         | Add support for C5d instance type                                                                                                   |
| 20230521         | Change default shell for the admin user to /etc/cli.sh                                                                              |
| 20221226         | Support ASG Launch Template instead of Launch Configuration                                                                         |
| 20221123         | Templates version 20221123 and higher support R81.20                                                                                |
| 20220606         | New instance type support                                                                                                           |
| 20210329         | Stability fixes                                                                                                                     |
| 20210309         | AWS Terraform modules refactor                                                                                                      |
| 20200318         | First release of Check Point Auto Scaling Terraform module for AWS                                                                  |
