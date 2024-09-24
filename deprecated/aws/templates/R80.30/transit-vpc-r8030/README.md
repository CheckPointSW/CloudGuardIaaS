
## Security Transit VPC
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
            <td rowspan="4" width="40%">
                Deploys two Security Gateways, each in a different Availability Zone, configured for Transit VPC.<br/><br/> For more details, refer to <a href="https://sc1.checkpoint.com/documents/R80.10/WebAdminGuides/EN/CP_Transit_VPC_for_AWS/html_frameset.htm">Transit VPC for AWS Deployment Guide </a>.
            </td>
            <td width="40%">Creates a new VPC and deploys two Check Point Gateways for a Transit VPC hub into it, and an optional, preconfigured Security Management Server to manage them.</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/cluster/checkpoint-transit-master.yaml&stackName=Check-Point-Transit-VPC"><img src="../../../../aws/images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">Deploys two Check Point Gateways for a Transit VPC hub into an existing VPC, and an optional, preconfigured Security Management Server to manage them.</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/cluster/checkpoint-transit.yaml&stackName=Check-Point-Transit-VPC"><img src="../../../../aws/images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">Creates a new VPC and deploys two Security Gateways into it.	</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/cluster/transit-master.yaml&stackName=Check-Point-Transit-VPC"><img src="../../../../aws/images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">Deploys two Security Gateways into an existing VPC.</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/cluster/transit.yaml&stackName=Check-Point-Transit-VPC"><img src="../../../../aws/images/launch.png"/></a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>