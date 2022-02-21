# R80 Security Management Server
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
           Deploys an R80 Security Management Server / Multi-Domain Security Management Server.  This template will run the First Time Configuration Wizard automatically and configure the machine as a Security Management Server.
            </td>
            <td width="40%">The AWS marketplace listing for R80 is available only for customers that are already subscribed. New customers should use R80.10 listing. </td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https%3A%2F%2Fs3.amazonaws.com%2FCloudFormationTemplate%2Fr80.json&stackName=Check-Point-R80"><img src="../../../../aws/images/launch.png"/></a></td>
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
4. Select "*Upload a template file*" and then "*Choose file*"
5. Load the "*r80.json*" file from this directory and click "*Next*"
6. Enter the desired template parameters
7. Click *Next* until you can review the configurations.
8. After you've reviewed the configuraitons, click "*Create stack*".