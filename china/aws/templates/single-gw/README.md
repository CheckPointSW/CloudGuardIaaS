## Security Gateway
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
            Deploys and configures a Security Gateway. <br/><br/> To deploy the Security Gateway so that it will be automatically provisioned, refer to <a href="https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk131434">sk131434</a>. 
            </td>
            <td width="40%">Creates a new VPC and deploys a Security Gateway into it.</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/gateway/gateway-master.yaml&stackName=Check-Point-Gateway"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">Deploys a Security Gateway into an existing VPC.</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/gateway/gateway.yaml&stackName=Check-Point-Gateway"><img src="../../images/launch.png"/></a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Revision History
In order to check the template version, please refer to [sk125252](https://support.checkpoint.com/results/sk/sk125252#ToggleR8120gateway)

| Template Version | Description                                                                                                   |
|------------------|---------------------------------------------------------------------------------------------------------------|
| 20240704         | - R80.40 version deprecation.<br/>- R81 version deprecation.                                                  |
| 20240519         | Add support for requiring use instance metadata service version 2 (IMDSv2) only                               |
| 20231113         | Stability fixes.                                                                                              |
| 20230923         | Add support for C5d instance type.                                                                            |
| 20230521         | - Change default shell for the admin user to /etc/cli.sh<br/>- Add description for reserved words in hostname |
| 20230503         | Template version 20230503 and above supports Smart-1 Cloud token validation.                                  |
| 20230411         | Improved deployment experience for gateways and clusters managed by Smart-1 Cloud                             |
| 20221123         | Templates version 20221120 and above support R81.20                                                           |
| 20220606         | New instance type support.                                                                                    |
