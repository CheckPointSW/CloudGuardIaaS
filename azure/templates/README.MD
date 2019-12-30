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
