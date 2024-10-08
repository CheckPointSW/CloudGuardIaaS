# Azure Resource Manager templates
This directory contains the CloudGuard IaaS solution templates published in the [Azure Marketplace](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/checkpoint.vsec?tab=Overview).

# How to deploy templates manually
To deploy the ARM templates manually without using the Azure Marketplace, follow these instructions:
1. Log in to the [Microsoft Azure Portal](https://portal.azure.com)
2. Click "*Create a resource*"
3. Search for "*Template deployment (deploy using custom templates)*" and click "*Create*"
4. Click "*Build your own template in the editor*"
5. Load the "*mainTemplate.json*" file of the desired template and click "*Save*"
6. Enter the desired template parameters
   - Replace the "*_artifacts Location*" property with:
      ```
      https://raw.githubusercontent.com/CheckPointSW/CloudGuardIaaS/master/azure/templates/
      ```
7. Click *Purchase* to deploy the solution

# How to deploy a specific version of Azure image
<details>
Please note that we recommend using the latest image.

To deploy a specific Azure image, adjust the image version during the manual deployment of ARM templates and follow these instructions:

1. Determine the desired image version - 
   - Visit  [sk132192 - CloudGuard Network Security for Azure - Latest Updates](https://support.checkpoint.com/results/sk/sk132192#:~:text=CloudGuard%20for%20Azure%20Gateway%20Images%20history) >
   Images History sections.
   - Find the version of the desired image under "Marketplace Image version"


2. In the "mainTemplate.json" file, change the value of the **“version”** parameter from “latest” to the version you want to deploy. This must be done under the version type of image you want to deploy (sg-byol, sg-ngtp, etc.)
	
	**Example** for SG-BYOL (Bring your own license):  
	**Change from:**
	
	"imageReferenceBYOL":{  
	"offer": "[variables('imageOffer')]",  
	"publisher": "[variables('imagePublisher')]",  
	"sku": "sg-byol",  
	"version": "**latest**" },
	
	**to:**  
	"imageReferenceBYOL":{  
	"offer": "[variables('imageOffer')]",  
	"publisher": "[variables('imagePublisher')]",  
	"sku": "sg-byol",  
    "version": "**8110.900335.1498**" },  


3. To confirm the version, run the command on the deployed machine:  
  **'more /etc/cloud-version'**

   **Output for -  R81.20-631.1475:**  
    release: R81.20  
	take: 631  
	build: 991001475  
	platform: azure  
	license: byol  
	deployment_method: ftw  
	template_name: management  
	template_version: 20231002  
	template_type: marketplace  
</details>
