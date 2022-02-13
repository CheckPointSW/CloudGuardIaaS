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
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/autoscale/checkpoint-tgw-asg-master.yaml&stackName=Check-Point-TGW-AutoScaling"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">Deploys an Auto Scaling group of Security Gateways configured for Transit Gateway into an existing VPC, and an optional, preconfigured Security Management Server to manage them.	</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/autoscale/checkpoint-tgw-asg.yaml&stackName=Check-Point-TGW-AutoScaling"><img src="../../images/launch.png"/></a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>