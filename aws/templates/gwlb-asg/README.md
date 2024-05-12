
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
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/gwlb/gwlb-master.yaml"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">
            Deploys and configures an AWS Auto Scaling group configured for Gateway Load Balancer in a Centralized Security VPC.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Gateway_Load_Balancer_ASG/Default.htm">CloudGuard Network for AWS Centralized Gateway Load Balancer R80.40 Deployment Guide</a>.
            </td>
            <td width="40%">Deploys a Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, and optionally a Security Management Server into an existing VPC.</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/gwlb/gwlb.yaml"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">
            Deploys and configures an AWS Auto Scaling group configured for Gateway Load Balancer in a Centralized Security VPC for Transit Gateway.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Gateway_Load_Balancer_ASG/Default.htm">CloudGuard Network for AWS Gateway Load Balancer Security VPC for Transit Gateway R80.40 Deployment Guide</a>.
            </td>
            <td width="40%">Creates a new VPC and deploys into it a Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, and optionally a Security Management Server, Gateway Load Balancer Endpoints and NAT Gateways for each AZ, for Transit Gateway. </td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/gwlb/tgw-gwlb-master.yaml"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">
            Deploys and configures an AWS Auto Scaling group configured for Gateway Load Balancer in a Centralized Security VPC for Transit Gateway.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Gateway_Load_Balancer_ASG/Default.htm">CloudGuard Network for AWS Gateway Load Balancer Security VPC for Transit Gateway R80.40 Deployment Guide</a>.
            </td>
            <td width="40%">Deploys a Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, and optionally a Security Management Server, Gateway Load Balancer Endpoints and NAT Gateways for each AZ, for Transit Gateway into an existing VPC.</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/gwlb/tgw-gwlb.yaml"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">
            Deploys and configures a Quick Start AWS Auto Scaling Group configured for Gateway Load Balancer in a Centralized Security VPC, and Servers in Servers VPC<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Gateway_Load_Balancer_ASG/Default.htm">CloudGuard Network for AWS Centralized Gateway Load Balancer R80.40 Deployment Guide</a>.
            </td>
            <td width="40%">Creates a new Security VPC with Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, Servers' VPC with Gateway Load Balancer Endpoints (1 per Availability Zone), Application Load Balancer in Servers' VPC, Servers and optionally a Security Management Server.</br>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/gwlb/qs-gwlb-master.yaml"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">
            Deploys and configures a Quick Start AWS Auto Scaling Group configured for Gateway Load Balancer in a Centralized Security VPC, and Servers in Servers VPC.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Gateway_Load_Balancer_ASG/Default.htm">CloudGuard Network for AWS Centralized Gateway Load Balancer R80.40 Deployment Guide</a>.
            </td>
<<<<<<< HEAD
            <td width="40%">Deploys a Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, optionally a Security Management Server into an existing Security VPC, Gateway Load Balancer Endpoints (1 per Availability Zone), Application Load Balancer and Servers into an existing Servers' VPC.</br>
=======
            <td width="40%">Deploys a Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, optionally a Security Management Server into an existing Security VPC, Gateway Load Balancer Endpoints (1 per Availability Zone), Application Load Balancer and Servers into an existing in Servers' VPC.</br>
>>>>>>> 6667c7f (remove message)
			</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/gwlb/qs-gwlb.yaml"><img src="../../images/launch.png"/></a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>
