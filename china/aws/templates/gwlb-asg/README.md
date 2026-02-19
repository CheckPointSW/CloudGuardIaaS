
## Gateway Load Balancer (GWLB) Auto Scaling Group
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
            Deploys and configures an AWS Auto Scaling group configured for Gateway Load Balancer in a Centralized Security VPC.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Gateway_Load_Balancer_ASG/Default.htm">CloudGuard Network for AWS Centralized Gateway Load Balancer R80.40 Deployment Guide</a>.
            </td>
            <td width="40%">Creates a new VPC and deploys into it a Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, and optionally a Security Management Server.</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/gwlb/gwlb-master.yaml"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">
            Deploys and configures an AWS Auto Scaling group configured for Gateway Load Balancer in a Centralized Security VPC.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Gateway_Load_Balancer_ASG/Default.htm">CloudGuard Network for AWS Centralized Gateway Load Balancer R80.40 Deployment Guide</a>.
            </td>
            <td width="40%">Deploys a Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, and optionally a Security Management Server into an existing VPC.</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/gwlb/gwlb.yaml"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">
            Deploys and configures an AWS Auto Scaling group configured for Gateway Load Balancer in a Centralized Security VPC for Transit Gateway.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Gateway_Load_Balancer_ASG/Default.htm">CloudGuard Network for AWS Gateway Load Balancer Security VPC for Transit Gateway R80.40 Deployment Guide</a>.
            </td>
            <td width="40%">Creates a new VPC and deploys into it a Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, and optionally a Security Management Server, Gateway Load Balancer Endpoints and NAT Gateways for each AZ, for Transit Gateway. </td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/gwlb/tgw-gwlb-master.yaml"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">
            Deploys and configures an AWS Auto Scaling group configured for Gateway Load Balancer in a Centralized Security VPC for Transit Gateway.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Gateway_Load_Balancer_ASG/Default.htm">CloudGuard Network for AWS Gateway Load Balancer Security VPC for Transit Gateway R80.40 Deployment Guide</a>.
            </td>
            <td width="40%">Deploys a Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, and optionally a Security Management Server, Gateway Load Balancer Endpoints and NAT Gateways for each AZ, for Transit Gateway into an existing VPC.</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/gwlb/tgw-gwlb.yaml"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">
            Deploys and configures a Quick Start AWS Auto Scaling Group configured for Gateway Load Balancer in a Centralized Security VPC, and Servers in Servers VPC<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Gateway_Load_Balancer_ASG/Default.htm">CloudGuard Network for AWS Centralized Gateway Load Balancer R80.40 Deployment Guide</a>.
            </td>
            <td width="40%">Creates a new Security VPC with Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, Servers' VPC with Gateway Load Balancer Endpoints (1 per Availability Zone), Application Load Balancer in Servers' VPC, Servers and optionally a Security Management Server.</br>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/gwlb/qs-gwlb-master.yaml"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">
            Deploys and configures a Quick Start AWS Auto Scaling Group configured for Gateway Load Balancer in a Centralized Security VPC, and Servers in Servers VPC.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Gateway_Load_Balancer_ASG/Default.htm">CloudGuard Network for AWS Centralized Gateway Load Balancer R80.40 Deployment Guide</a>.
            </td>
            <td width="40%">Deploys a Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, optionally a Security Management Server into an existing Security VPC, Gateway Load Balancer Endpoints (1 per Availability Zone), Application Load Balancer and Servers into an existing Servers' VPC.</br>
			</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/gwlb/qs-gwlb.yaml"><img src="../../images/launch.png"/></a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Revision History
In order to check the template version, please refer to [sk125252](https://support.checkpoint.com/results/sk/sk125252#ToggleR8120gateway)

| Template Version | Description                                                                                                   |
|------------------|---------------------------------------------------------------------------------------------------------------|
| 20240704         | - R80.40 version deprecation.<br/>- R81 version  deprecation                                                  |
| 20240519         | Add support for requiring use instance metadata service version 2 (IMDSv2) only                               |
| 20240414         | Add support for Elastic Load Balancer Health Checks.                                                          |
| 20230923         | Add support for C5d instance type.                                                                            |
| 20230521         | - Change default shell for the admin user to /etc/cli.sh<br/>- Add description for reserved words in hostname |
| 20221226         | Support ASG Launch Template instead of Launch Configuration.                                                  |
| 20221123         | Templates version 20221120 and above support R81.20                                                           |
| 20220606         | New instance type support                                                                                     |
| 20220414         | First release of Check Point Auto Scaling GWLB Terraform module for AWS                                       |
