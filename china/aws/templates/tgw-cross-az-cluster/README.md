
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
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/cluster/tgw-cross-az-cluster-master.yaml&stackName=Check-Point-TGW-Cross-AZ-Cluster"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">Deploys a Cross Availability Zone Cluster of Security Gateways configured for Transit Gateway into an existing VPC.</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/cluster/cross-az-cluster.yaml&stackName=Check-Point-TGW-Cross-AZ-Cluster"><img src="../../images/launch.png"/></a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>
## Revision History
In order to check the template version, please refer to [sk116585](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk116585)

| Template Version | Description                                                                                                                                           |
|------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|
| 20240519         | Add support for requiring use instance metadata service version 2 (IMDSv2) only                                                                       |
| 20230923         | Add support for C5d instance type.                                                                                                                    |
| 20230521         | - Change default shell for the admin user to /etc/cli.sh<br/>- Add description for reserved words in hostname                                         |
| 20230503         | Smart-1 Cloud token validation.                                                                                                                       |
| 20230411         | - Improved deployment experience for gateways and clusters managed by Smart-1 Cloud.<br/>- Multiple VIPs support for Cross Availability Zone Cluster. |
| 20221229         | Removed unsupported versions.                                                                                                                         |
| 20221123         | Templates version 20221120 and above support R81.20                                                                                                   |
