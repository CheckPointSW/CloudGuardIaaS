
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
            Deploys and configures an AWS Auto Scaling group configured for Gateway Load Balancer in a Centralized Security VPC.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Centralized_Gateway_Load_Balancer/Default.htm">CloudGuard Network for AWS Centralized Gateway Load Balancer R80.40 Deployment Guide</a>.
            </td>
            <td width="40%">Creates a new VPC and deploys into it a Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, and optionally a Security Management Server.</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/gwlb/gwlb-master.yaml"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">
            Deploys and configures an AWS Auto Scaling group configured for Gateway Load Balancer in a Centralized Security VPC for Transit Gateway.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Gateway_Load_Balancer_Security_VPC_for_Transit_Gateway/Default.htm">CloudGuard Network for AWS Gateway Load Balancer Security VPC for Transit Gateway R80.40 Deployment Guide</a>.
            </td>
            <td width="40%">Creates a new VPC and deploys into it a Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, and optionally a Security Management Server, Gateway Load Balancer Endpoints and NAT Gateways for each AZ, for Transit Gateway. </td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/gwlb/tgw-gwlb-master.yaml"><img src="../../images/launch.png"/></a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>
