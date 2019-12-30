# How to deploy this template
To deploy this ARM template, follow these instructions:
1. Log in to the [Microsoft Azure Portal](https://portal.azure.com)
2. Click "*Create a resource*"
3. Search for "*Template deployment (deploy using custom templates)*" and click "*Create*"
4. Click "*Build your own template in the editor*"
5. Load the "*mainTemplate.json*" file from this directory and click "*Save*"
6. Enter the desired template parameters
   - Replace the "*Base Url*" property with:
      ```
      https://raw.githubusercontent.com/CheckPointSW/CloudGuardIaaS/master/deprecated/azure/templates/mgmt-r7730
      ```
7. Click *Purchase* to deploy the solution
