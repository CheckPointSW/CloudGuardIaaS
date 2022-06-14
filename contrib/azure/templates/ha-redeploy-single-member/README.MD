# ARM CloudGuard High Availability template to redeploy Cluster member

This directory contains the CloudGuard IaaS HA template derived from the ´20220130` version of the template .

This template adds the ability to redeploy a single member of a HA cluster into the same Resource Group of an existing Ha cluster withouth the need to redeploy the whole cluster. 

The template is specially useful in the following use cases:
1 - Redeploy/Replace a single memeber of a cluster that has failed on the same version.
2 - Perform an upgrade of the Cluster using MVC (Multi-version cluster)


The logic of the template is to simply replace one VM and re-attach the old NIC’s and Public addresses and deploy on the same resource group as the old VM. 

NOTE 1: IAM roles must be configured manually since the template fails to update the resource group.
NOTE 2: Deploys a new Storage account dedicated to the new deployed VM.

## How to deploy the template:

Note: Backup device according to sk169814 (if possible).

1.	Log in to the Microsoft Azure Portal
2.	Locate the resource group where the cluster is installed into
3.	Proceed to delete failed Virtual Machine. 
a.	Select to delete associated Disk but to retain existing NIC and Public Addresses
4.	Click “Create a Resource”
5.	Log in to the Microsoft Azure Portal
6.	Search for "Template deployment (deploy using custom templates)" and click "Create"
7.	Click "Build your own template in the editor"
8.	Load the "ha-redeploy-single-member.json" file of the desired template and click "Save"
9.	Enter the desired template parameters.
a.	NOTE: Pay close attention to correctly fill the information relevant to the cluster name and member ID and match the resource group and VM size.
b.	Specify the Virtual Network name, resource group and cluster-vip of the cluster.
c.	Replace the "_artifacts Location" property with: https://raw.githubusercontent.com/CheckPointSW/CloudGuardIaaS/master/azure/templates/
10.	Click Purchase to deploy the solution
11.	Once deployment is completed. Verify IAM roles and permissions of the new VM. 
12.	Restore any clish backups. 
13.	Open SmartConsole, re-establishing SIC.
	13.a	For Member Recovery: Re-install policy and test failover
	13.b	For Upgrades: Perform MVC upgrade process as per documentation and then repeat all steps for second member to be upgraded.

