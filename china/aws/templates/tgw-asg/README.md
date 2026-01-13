
## Transit Gateway Auto Scaling Group
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
            <td rowspan="2" width="40%">
           Deploys and configured the Security Gateways as an AWS Auto Scaling group configured for Transit Gateway.<br/><br/> For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_AWS_Transit_Gateway/Default.htm" >AWS Transit Gateway R80.10 and above Deployment Guide</a>.
            </td>
            <td width="40%">Creates a new VPC and deploys an Auto Scaling group of Security Gateways configured for Transit Gateway into it, and an optional, preconfigured Security Management Server to manage them.</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/autoscale/tgw-asg-master.yaml&stackName=Check-Point-TGW-AutoScaling"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">Deploys an Auto Scaling group of Security Gateways configured for Transit Gateway into an existing VPC, and an optional, preconfigured Security Management Server to manage them.	</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/autoscale/tgw-asg.yaml&stackName=Check-Point-TGW-AutoScaling"><img src="../../images/launch.png"/></a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Revision History
In order to check the template version, please refer to [sk116585](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk116585)

| Template Version | Description                                                                              |
|------------------|------------------------------------------------------------------------------------------|
| 20240704         | - R80.40 version deprecation.<br/>- R81 version deprecation.                             |
| 20240519         | Add support for requiring use instance metadata service version 2 (IMDSv2) only          |
| 20240414         | Add support for Elastic Load Balancer Health Checks.                                     |
| 20230923         | Add support for C5d instance type.                                                       |
| 20221226         | Support ASG Launch Template instead of Launch Configuration.                             |
| 20221123         | Templates version 20221120 and above support R81.20                                      |
| 20220606         | New instance type support.                                                               |
| 20210329         | First release of Check Point Transit Gateway Auto Scaling Group Terraform module for AWS |
