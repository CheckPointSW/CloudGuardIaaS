# Deprecated AWS CloudFormation Templates

[CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html) is an Amazon Web Services (AWS) service that enables modeling and setting up resources inside AWS in an automated fashion.


The table below lists CloudFormation templates provided and maintained by Check Point that simplify the deployment of Check Point security solutions in AWS.  

You can use these templates as-is or as building blocks for customizing your own templates.

**Notes:**

* You must accept the Software Terms of the relevant Check Point Product AMI in the [AWS Marketplace](https://aws.amazon.com/marketplace/) at least once prior to launching the CloudFormation templates. It is not required to actually launch the instance from the Marketplace, but the agreement must be accepted from this location.

* Some stacks may "roll back" automatically after 1 hour, with an error "WaitCondition timed out" If this happens, please check Internet access is working, either through AWS (Internet Gateway (IGW) assigned to the VPC, routetables with a default route and assigned to the relevant subnet(s), and Elastic IP (EIP) assigned, etc), or through another method like external proxy, or route to on-prem, for example. 

**Table of Contents**

* Security Gateway
* Security Cluster
* Security Gateway Auto Scaling
* Transit Gateway Auto Scaling Group
* Security Transit VPC
* Security Management Server
* Multi-Domain Management Server

<br/>
<br/>

## Security Gateway
<table>
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
            <td rowspan="2">
            Deploys and configures a Security Gateway. <br/><br/> To deploy the Security Gateway so that it will be automatically provisioned, refer to <a href="https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk131434">sk131434</a>. 
            </td>
            <td>Creates a new VPC and deploys a Security Gateway into it.</td>
            <td>R80.30</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/gateway/gateway.json&stackName=Check-Point-Gateway">Launch Stack</a></td>
        </tr>
        <tr>
            <td>Deploys a Security Gateway into an existing VPC.</td>
            <td>R80.30</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/gateway/gateway-into-vpc.json&stackName=Check-Point-Gateway">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Security Cluster
<table>
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
            <td rowspan="2">
           Deploys and configures two Security Gateways as a Cluster.<br/><br/>For more details, refer to the <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CloudGuard_Network_for_AWS_Cluster_DeploymentGuide/Default.htm">CloudGuard Network for AWS Security Cluster R80.20 and Higher Deployment Guide</a>. 
            </td>
            <td>Creates a new VPC and deploys a Cluster into it.</td>
            <td>R80.30</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/cluster/cluster.json&stackName=Check-Point-Cluster">Launch Stack</a></td>
        </tr>
        <tr>
            <td>Deploys a Cluster into an existing VPC.	</td>
            <td>R80.30</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/cluster/cluster-into-vpc.json&stackName=Check-Point-Cluster">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Security Gateway Auto Scaling
<table>
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
            <td>
           Deploys and configures the Security Gateways as an AWS Auto Scaling group. <br/><br/> For more details, refer to the <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CloudGuard_Network_for_AWS_AutoScaling_DeploymentGuide/Default.htm" >CloudGuard Network Auto Scaling for AWS R80.20 and Higher Deployment Guide </a>. 
            </td>
            <td>Deploys an Auto Scaling group of Security Gateways into an existing VPC.</td>
            <td>R80.30</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/autoscale/autoscale.json&stackName=Check-Point-Security-Gateway-AutoScaling">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Transit Gateway Auto Scaling Group
<table>
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
            <td rowspan="2">
           Deploys and configured the Security Gateways as an AWS Auto Scaling group configured for Transit Gateway.<br/><br/> For more details, refer to <a href="https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_AWS_Transit_Gateway/Default.htm" >AWS Transit Gateway R80.10 and above Deployment Guide</a>.
            </td>
            <td>Creates a new VPC and deploys an Auto Scaling group of Security Gateways configured for Transit Gateway into it, and an optional, preconfigured Security Management Server to manage them.</td>
            <td>R80.30</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/autoscale/checkpoint-tgw-asg-master.yaml&stackName=Check-Point-TGW-AutoScaling">Launch Stack</a></td>
        </tr>
        <tr>
            <td>Deploys an Auto Scaling group of Security Gateways configured for Transit Gateway into an existing VPC, and an optional, preconfigured Security Management Server to manage them.	</td>
            <td>R80.30</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/autoscale/checkpoint-tgw-asg.yaml&stackName=Check-Point-TGW-AutoScaling">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Security Transit VPC
<table>
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
            <td rowspan="4">
                Deploys two Security Gateways, each in a different Availability Zone, configured for Transit VPC.<br/><br/> For more details, refer to <a href="https://sc1.checkpoint.com/documents/R80.10/WebAdminGuides/EN/CP_Transit_VPC_for_AWS/html_frameset.htm">Transit VPC for AWS Deployment Guide </a>.
            </td>
            <td>Creates a new VPC and deploys two Check Point Gateways for a Transit VPC hub into it, and an optional, preconfigured Security Management Server to manage them.</td>
            <td>R80.30</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/cluster/checkpoint-transit-master.yaml&stackName=Check-Point-Transit-VPC">Launch Stack</a></td>
        </tr>
        <tr>
            <td>Deploys two Check Point Gateways for a Transit VPC hub into an existing VPC, and an optional, preconfigured Security Management Server to manage them.</td>
            <td>R80.30</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/cluster/checkpoint-transit.yaml&stackName=Check-Point-Transit-VPC">Launch Stack</a></td>
        </tr>
        <tr>
            <td>Creates a new VPC and deploys two Security Gateways into it.	</td>
            <td>R80.30</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/cluster/transit-master.yaml&stackName=Check-Point-Transit-VPC">Launch Stack</a></td>
        </tr>
        <tr>
            <td>Deploys two Security Gateways into an existing VPC.</td>
            <td>R80.30</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/cluster/transit.yaml&stackName=Check-Point-Transit-VPC">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Security Management Server
<table>
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
            <td>
                Deploys and configures a Security Management Server.<br/><br/>For more details, refer to <a href="https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk130372">sk130372</a>.
            </td>
            <td>Deploys a Security Management Server into an existing VPC.</td>
            <td>R80.30</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/management/management.json&stackName=Check-Point-Management">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>

## Multi-Domain Management Server
<table>
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
            <td>
           Deploys and configures a Multi-Domain Security Management Server. <br/><br/> For more details, refer to <a href="https://supportcenter.us.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk143213">sk143213</a>.
            </td>
            <td>Deploys a Multi-Domain Security Management Server into an existing VPC.</td>
            <td>R80.30</td>
            <td><a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://cgi-cfts.s3.amazonaws.com/deprecated/management/mds.json&stackName=Check-Point-MDS">Launch Stack</a></td>
        </tr>
    </tbody>
</table>
<br/>
<br/>