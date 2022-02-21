# R77.30 Security Gateway
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
    </tbody>
</table>
<br/>
<br/>

## How to deploy this template manually
To deploy this CloudFormation template, follow these instructions:
1. Log in and navigate to the [AWS CloudForamtion page](https://console.aws.amazon.com/cloudformation/)
2. Click "*Create stack*"
3. Click "*With new resources (standard)*"
4. Select "*Upload a tempalte file*" and then "*Choose file*"
5. Load the "*gateway-2-nic-existing-vpc.json*" file from this directory and click "*Next*"
6. Enter the desired template parameters
7. Click *Next* until you can review the configuration.
8. After you've reviewed the configuraiton, click "*Create stack*".
