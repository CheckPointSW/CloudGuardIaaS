# AWS CloudFormation Templates

[CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html) is an Amazon Web Services (AWS) service that enables modeling and setting up resources inside AWS in an automated fashion.


The table below lists CloudFormation templates provided and maintained by Check Point that simplify the deployment of Check Point security solutions in AWS.  

You can use these templates as-is or as building blocks for customizing your own templates.

**Notes:**

* You must accept the Software Terms of the relevant Check Point Product AMI in the [AWS Marketplace](https://aws.amazon.com/marketplace/) at least once prior to launching the CloudFormation templates. It is not required to actually launch the instance from the Marketplace, but the agreement must be accepted from this location.

* Some stacks may "roll back" automatically after 1 hour, with an error "WaitCondition timed out" If this happens, please check Internet access is working, either through AWS (Internet Gateway (IGW) assigned to the VPC, routetables with a default route and assigned to the relevant subnet(s), and Elastic IP (EIP) assigned, etc), or through another method like external proxy, or route to on-prem, for example. 


# Manual Deployment
In case you want to deploy a custom template that is not listed follow this steps:
1. ## Create Stack
    When in the CloudFormation service, click on "Create stack" button.
    ![Step 1](https://i.imgur.com/EOTQuTX.png)

2. ## Upload desired template
    Use this menu to upload your custom template (yaml/json file)
    ![Step 2](https://i.imgur.com/DszwjN6.png)
    After the file is uploaded, click next.

3. ## Specify stack details
    In this menu you'll need to specify the custom parameters for your template based on the template that you've uploaded.
    ![Step 3](https://i.imgur.com/rHyyiF8.png)
    When you done, click next.

4. ## Configure stack options
    If you need to configure your stack options (e.g. tags, iam role, and etc.) you can do it in this menu. 
    Click next to move to the review page.

5. ## Review and create stack.
    In this window, make sure all configured correctly. 
    If everything is correct, press "Create stack" and deploy the stack.
## Gateway Load Balancer (GWLB) Auto Scaling Group
<table width="80%">
    <thead>
        <tr>
            <th>Description</th>
            <th>Notes</th>
            <th>Version</th>
            <th>Direct Launch</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td width="40%">
            Deploys and configures an AWS Auto Scaling group configured for Gateway Load Balancer in a Centralized Security VPC.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Centralized_Gateway_Load_Balancer/Default.htm">CloudGuard Network for AWS Centralized Gateway Load Balancer R80.40 Deployment Guide</a>.
            </td>
            <td width="40%">Creates a new VPC and deploys into it a Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, and optionally a Security Management Server.</td>
            <td>R80.40</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/gwlb/gwlb-master.yaml">Launch Stack</a></td>
        </tr>
        <tr>
            <td width="40%">
            Deploys and configures an AWS Auto Scaling group configured for Gateway Load Balancer in a Centralized Security VPC for Transit Gateway.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_Network_for_AWS_Gateway_Load_Balancer_Security_VPC_for_Transit_Gateway/Default.htm">CloudGuard Network for AWS Gateway Load Balancer Security VPC for Transit Gateway R80.40 Deployment Guide</a>.
            </td>
            <td width="40%">Creates a new VPC and deploys into it a Gateway Load Balancer, Check Point CloudGuard IaaS Security Gateway Auto Scaling Group, and optionally a Security Management Server, Gateway Load Balancer Endpoints and NAT Gateways for each AZ, for Transit Gateway. </td>
            <td>R80.40</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/gwlb/tgw-gwlb-master.yaml">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Security Gateway
<table width="80%">
    <thead>
        <tr>
            <th>Description</th>
            <th>Notes</th>
            <th>Version</th>
            <th>Direct Launch</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan="2" width="40%">
            Deploys and configures a Security Gateway. <br/><br/> To deploy the Security Gateway so that it will be automatically provisioned, refer to <a href="https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk131434">sk131434</a>. 
            </td>
            <td width="40%">Creates a new VPC and deploys a Security Gateway into it.</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/gateway/gateway-master.yaml&stackName=Check-Point-Gateway">Launch Stack</a></td>
        </tr>
        <tr>
            <td width="40%">Deploys a Security Gateway into an existing VPC.</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/gateway/gateway.yaml&stackName=Check-Point-Gateway">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Security Cluster
<table width="80%">
    <thead>
        <tr>
            <th>Description</th>
            <th>Notes</th>
            <th>Version</th>
            <th>Direct Launch</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan="2" width="40%">
           Deploys and configures two Security Gateways as a Cluster.<br/><br/>For more details, refer to the <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CloudGuard_Network_for_AWS_Cluster_DeploymentGuide/Default.htm">CloudGuard Network for AWS Security Cluster R80.20 and Higher Deployment Guide</a>. 
            </td>
            <td width="40%">Creates a new VPC and deploys a Cluster into it.</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/cluster/cluster-master.yaml&stackName=Check-Point-Cluster">Launch Stack</a></td>
        </tr>
        <tr>
            <td width="40%">Deploys a Cluster into an existing VPC.	</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/cluster/cluster.yaml&stackName=Check-Point-Cluster">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Security Gateway Auto Scaling
<table width="80%">
    <thead>
        <tr>
            <th>Description</th>
            <th>Notes</th>
            <th>Version</th>
            <th>Direct Launch</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td width="40%">
           Deploys and configures the Security Gateways as an AWS Auto Scaling group. <br/><br/> For more details, refer to the <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CloudGuard_Network_for_AWS_AutoScaling_DeploymentGuide/Default.htm" >CloudGuard Network Auto Scaling for AWS R80.20 and Higher Deployment Guide </a>. 
            </td>
            <td width="40%">Deploys an Auto Scaling group of Security Gateways into an existing VPC.</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/autoscale/autoscale.yaml&stackName=Check-Point-Security-Gateway-AutoScaling">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Transit Gateway Auto Scaling Group
<table width="80%">
    <thead>
        <tr>
            <th>Description</th>
            <th>Notes</th>
            <th>Version</th>
            <th>Direct Launch</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan="2" width="40%">
           Deploys and configured the Security Gateways as an AWS Auto Scaling group configured for Transit Gateway.<br/><br/> For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_AWS_Transit_Gateway/Default.htm" >AWS Transit Gateway R80.10 and above Deployment Guide</a>.
            </td>
            <td width="40%">Creates a new VPC and deploys an Auto Scaling group of Security Gateways configured for Transit Gateway into it, and an optional, preconfigured Security Management Server to manage them.</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/autoscale/tgw-asg-master.yaml&stackName=Check-Point-TGW-AutoScaling">Launch Stack</a></td>
        </tr>
        <tr>
            <td width="40%">Deploys an Auto Scaling group of Security Gateways configured for Transit Gateway into an existing VPC, and an optional, preconfigured Security Management Server to manage them.	</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/autoscale/tgw-asg.yaml&stackName=Check-Point-TGW-AutoScaling">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Transit Gateway Cross Availability Zone Cluster
<table width="80%">
    <thead>
        <tr>
            <th>Description</th>
            <th>Notes</th>
            <th>Version</th>
            <th>Direct Launch</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan="2" width="40%">
           Deploys two Security Gateways, each in a different Availability Zone, configured for Transit Gateway.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_for_AWS_Transit_Gateway_High_Availability/Default.htm">CloudGuard Transit Gateway High Availability for AWS R80.40 Administration Guide</a>.
            </td>
            <td width="40%">Creates a new VPC and deploys a Cross Availability Zone Cluster of Security Gateways configured for Transit Gateway into it.</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/cluster/tgw-ha-master.yaml&stackName=Check-Point-TGW-HA">Launch Stack</a></td>
        </tr>
        <tr>
            <td width="40%">Deploys a Cross Availability Zone Cluster of Security Gateways configured for Transit Gateway into an existing VPC.</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/cluster/tgw-ha.yaml&stackName=Check-Point-TGW-HA">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Cross Availability Zone Cluster
<table width="80%">
    <thead>
        <tr>
            <th>Description</th>
            <th>Notes</th>
            <th>Version</th>
            <th>Direct Launch</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan="2" width="40%">
                Deploys two Security Gateways, each in a different Availability Zone.<br/><br/>For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_for_AWS_Transit_Gateway_High_Availability/Default.htm">CloudGuard Transit Gateway High Availability for AWS R80.40 Administration Guide</a>.
            </td>
            <td width="40%">Creates a new VPC and deploys a Cross Availability Zone Cluster of Security Gateways into it.</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/cluster/geo-cluster-master.yaml&stackName=Check-Point-geo-cluster">Launch Stack</a></td>
        </tr>
        <tr>
            <td width="40%">Deploys a Cross Availability Zone Cluster of Security Gateways into an existing VPC.</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/cluster/geo-cluster.yaml&stackName=Check-Point-geo-cluster">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Security Management Server
<table width="80%">
    <thead>
        <tr>
            <th>Description</th>
            <th>Notes</th>
            <th>Version</th>
            <th>Direct Launch</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td width="40%">
                Deploys and configures a Security Management Server.<br/><br/>For more details, refer to <a href="https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk130372">sk130372</a>.
            </td>
            <td width="40%">Deploys a Security Management Server into an existing VPC.</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/management/management.yaml&stackName=Check-Point-Management">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Multi-Domain Management Server
<table width="80%">
    <thead>
        <tr>
            <th>Description</th>
            <th>Notes</th>
            <th>Version</th>
            <th>Direct Launch</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td width="40%">
           Deploys and configures a Multi-Domain Security Management Server. <br/><br/> For more details, refer to <a href="https://supportcenter.us.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk143213">sk143213</a>.
            </td>
            <td width="40%">Deploys a Multi-Domain Security Management Server into an existing VPC.</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/management/mds.yaml&stackName=Check-Point-MDS">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>


## Security Management Server & Security Gateway (Standalone Deployment)
<table width="80%">
    <thead>
        <tr>
            <th>Description</th>
            <th>Notes</th>
            <th>Version</th>
            <th>Direct Launch</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td rowspan="2" width="40%">
                Deploys and configures Standalone or a manually configurable instance.
            </td>
            <td width="40%">Creates a new VPC and deploys a Standalone or a manually configurable instance into it.</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/gateway/standalone-master.yaml&stackName=Check-Point-Standalone">Launch Stack</a></td>
        </tr>
        <tr>
            <td width="40%">Deploys a Standalone or a manually configurable instance into an existing VPC.</td>
            <td>R80.40 and higher</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/gateway/standalone.yaml&stackName=Check-Point-Standalone">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## General
<table width="80%">
    <thead>
        <tr>
            <th>Description</th>
            <th>Direct Launch</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
                <b>Create a IAM Role for Security Management Server</b><br/>
                Creates a IAM role in your account preconfigured with permissions to manage resources.<br/>    
                For more details, refer to <a href="https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk122074">sk122074 </a>.
            </td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/iam/cme-iam-role.yaml&stackName=Check-Point-IAM-Role">Launch Stack</a></td>
        </tr>
        <tr>
            <td>
                <b>Current Check Point AMIs</b> <br/>
                A helper template that returns the latest Check Point AMIs in a given region.
            </td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/utils/amis.yaml&stackName=Check-Point-AMIs">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>
