
## R77.30 Security Gateway
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
           Deploys an externally managed R77.30 Security Gateway into an existing VPC. This template will run the First Time Configuration Wizard automatically and configure the machine as a Security Gateway. 
            </td>
            <td width="40%" style="text-align:center">---</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https%3A%2F%2Fs3.amazonaws.com%2FCloudFormationTemplate%2Fgateway-2-nic-existing-vpc.json&stackName=Check-Point-2-NIC"><img src="../../../../aws/images/launch.png"/></a></td>
        </tr>
        <tr>
            <td width="40%">
           Creates a new VPC and deploys an R77.30 instance.  This template does not run the First Time Configuration Wizard.
            </td>
            <td width="40%"><b>Does not</b> run the First Time Configuration Wizard.</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https%3A%2F%2Fs3.amazonaws.com%2FCloudFormationTemplate%2Fgwinvpc.json&stackName=Check-Point-Security-Gateway"><img src="../../../../aws/images/launch.png"/></a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>