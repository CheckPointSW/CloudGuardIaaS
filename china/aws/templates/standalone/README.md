
## Security Management Server & Security Gateway (Standalone Deployment)
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
                Deploys and configures Standalone or a manually configurable instance.
            </td>
            <td width="40%">Creates a new VPC and deploys a Standalone or a manually configurable instance into it.</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/gateway/standalone-master.yaml&stackName=Check-Point-Standalone"><img src="../../images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">Deploys a Standalone or a manually configurable instance into an existing VPC.</td>
            <td><a href="https://console.amazonaws.cn/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.cn-northwest-1.amazonaws.com.cn/gateway/standalone.yaml&stackName=Check-Point-Standalone"><img src="../../images/launch.png"/></a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Revision History
In order to check the template version, please refer to [sk116585](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk116585)

| Template Version | Description                                                                                                       |
|------------------|-------------------------------------------------------------------------------------------------------------------|
| 20240704         | - R80.40 version deprecation.<br/>- R81 version deprecation.                                                      |
| 20240519         | Add support for requiring use instance metadata service version 2 (IMDSv2) only                                   |
| 20231113         | - Stability fixes.<br/>- Add support for BYOL license type for Standalone.                                        |
| 20230923         | Add support for C5d instance type                                                                                 |
| 20230521         | - Change default shell for the admin user to /etc/cli.sh<br/>- Add description for reserved words in hostname     |
| 20221123         | Templates version 20221120 and above support R81.20                                                               |
| 20220606         | New instance type support                                                                                         |
| 20210329         | Stability fixes                                                                                                   |
| 20210309         | First release of Check Point Security Management Server & Security Gateway (Standalone) Terraform module for AWS  |
