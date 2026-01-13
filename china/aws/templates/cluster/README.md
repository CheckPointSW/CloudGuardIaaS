## Security Cluster

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
           Deploys and configures two Security Gateways as a Cluster.<br/><br/>For more details, refer to the <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CloudGuard_Network_for_AWS_Cluster_DeploymentGuide/Default.htm">CloudGuard Network for AWS Security Cluster R80.20 and Higher Deployment Guide</a>. 
            </td>
            <td width="40%">Creates a new VPC and deploys a Cluster into it.</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/cluster/cluster-master.yaml&stackName=Check-Point-Cluster"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">Deploys a Cluster into an existing VPC.	</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/cluster/cluster.yaml&stackName=Check-Point-Cluster"><img src="../../images/launch.png"/></a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>
## Revision History
In order to check the template version, please refer to [sk125252](https://support.checkpoint.com/results/sk/sk125252#ToggleR8120gateway)

| Template Version | Description                                                                                                      |
|------------------|------------------------------------------------------------------------------------------------------------------|
| 20240704         | - R80.40 version deprecation.<br/>- R81 version deprecation.                                                     |
| 20240519         | Add support for requiring use instance metadata service version 2 (IMDSv2) only                                  |
| 20230923         | Add support for C5d instance type.                                                                               |
| 20230521         | - Change default shell for the admin user to /etc/cli.sh<br/>- Add description for reserved words in hostname    |
| 20230503         | Template version 20230503 and above supports Smart-1 Cloud token validation.                                     |
| 20230411         | Improved deployment experience for gateways and clusters managed by Smart-1 Cloud.                               |
| 20221123         | Templates version 20221120 and above support R81.20                                                              |
| 20220606         | New instance type support                                                                                        |
| 20210309         | First release of Check Point Security Management Server & Security Gateway (Standalone) Terraform module for AWS |
