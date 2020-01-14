# ARM CloudGuard IaaS Scale Set with instances' public IPs allocated from an existing public IP prefix

This directory contains the CloudGuard IaaS VMSS template derived from the 20191003 vmss-v2 Marketplace scale set template.
This template adds the ability to allocate IP addresses for instances from an existing public IP prefix.
The VM scale set is deployed in the same existing resource group which includes the public IP prefix.

## Changes from Marketplace template
* added parameters:
-- `existingPublicIPprefixGroupName`
-- `existingPublicIPprefixName`

* added variables:
-- `existingPublicIPprefixResID` : constructs the public IP prefix ID from the parameters declared above, ID to be referenced in `publicIPProperties` existing variable

* changed declarations:
-- `publicIPProperties`
-- hardcoded nested templates locations

# How to deploy the template:

## Local deployment: download this template, construct a parameters.json file and run your deployment tool of choice, e. g.

```
az group deployment create -g <existing-resource-group-name> --template-file vmss-publicipprefix-instances.json --parameters @parameters.json --debug
```

### *Extra*: to load the administrator password from an existing keyvault (provided that you declared appropriate permissions), include in the parameters.json file in the parameters section:
```
"adminPassword": {
  "reference": {
    "keyVault": {
      "id": "/subscriptions/your-subscription-id-here/resourceGroups/your-resource-group-here/providers/Microsoft.KeyVault/vaults/your-keyvault-name-here",
      "secretName": "your-secret-name"
    } 
},
```
It might be useful to include also a ssh public key in the parameters section of the parameters.json file.

## To deploy the ARM templates manually without using the Azure Marketplace:
1. Log in to the [Microsoft Azure Portal](https://portal.azure.com)
2. Click "*Create a resource*"
3. Search for "*Template deployment (deploy using custom templates)*" and click "*Create*"
4. Click "*Build your own template in the editor*"
5. Load the "*vmss-publicipprefix-instances.json*" file of the desired template and click "*Save*"
6. Enter the required and/or optional template parameters
7. Click *Purchase* to deploy the solution
8. Debug the deployment
