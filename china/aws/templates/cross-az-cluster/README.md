
## Cross Availability Zone Cluster
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
                Deploys two Security Gateways, each in a different Availability Zone.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_for_AWS_Cross_AZ_Cluster/Default.htm">Cross Availability Zone Cluster for AWS R81.20 Administration Guide</a>.
            </td>
            <td width="40%">Creates a new VPC and deploys a Cross Availability Zone Cluster of Security Gateways into it.</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/cluster/cross-az-cluster-master.yaml&stackName=Check-Point-Cross-AZ-Cluster"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">Deploys a Cross Availability Zone Cluster of Security Gateways into an existing VPC.</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/cluster/cross-az-cluster.yaml&stackName=Check-Point-Cross-AZ-Cluster"><img src="../../images/launch.png"/></a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>