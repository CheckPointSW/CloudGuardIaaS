
## Security Management Server
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
                Deploys and configures a Security Management Server.<br/><br/>For more details, refer to <a href="https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk130372">sk130372</a>.
            </td>
            <td width="40%">Deploys a Security Management Server into an existing VPC.</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/management/management.yaml&stackName=Check-Point-Management"><img src="../../images/launch.png"/></a></td>
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
| 20230923         | Add support for C5d instance type                                                                             | 
| 20230521         | - Change default shell for the admin user to /etc/cli.sh<br/>- Add description for reserved words in hostname |
| 20221123         | Templates version 20221120 and above support R81.20                                                           |
| 20220606         | New instance type support                                                                                     |
| 20210329         | Stability fixes                                                                                               |
| 20210309         | First release of Check Point Security Management Server Terraform module for AWS                              |
