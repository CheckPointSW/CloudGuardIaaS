
## Transit Gateway Cross Availability Zone Cluster
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
           Deploys two Security Gateways, each in a different Availability Zone, configured for Transit Gateway.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_for_AWS_Cross_AZ_Cluster/Default.htm">Cross Availability Zone Cluster for AWS R81.20 Administration Guide</a>.
            </td>
            <td width="40%">Creates a new VPC and deploys a Cross Availability Zone Cluster of Security Gateways configured for Transit Gateway into it.</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/cluster/tgw-cross-az-cluster-master.yaml&stackName=Check-Point-TGW-Cross-AZ-Cluster"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">Deploys a Cross Availability Zone Cluster of Security Gateways configured for Transit Gateway into an existing VPC.</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/cluster/cross-az-cluster.yaml&stackName=Check-Point-TGW-Cross-AZ-Cluster"><img src="../../images/launch.png"/></a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>