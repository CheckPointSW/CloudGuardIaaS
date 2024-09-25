# ARM CloudGuard High Availability public IPs allocated from public IP prefix

This directory contains the CloudGuard IaaS HA template derived from the ´20201102` version of the template .
This template adds the ability to create a public IP Prefix that is used to allocated the Public IP addresses for the cluster.

## Changes from Marketplace template
* added parameters:
  - `ipPrefix` - Set parameter to `'yes'` to deploy the prefix
  - `ipPrefixSize`- Size of the Public IP Prefix, `/30`, `/29` or `/28`

* added variables:
  - `ipPrefixName` : constructs the public IP prefix name
  - `publicIPPrefixProperty` : constructs the public IP prefix property that will be added to app Public IPs if the `ipPrefix` parameter is set to 'yes'

* added resources:
  - Public IP Prefix `Microsoft.Network/publicipprefixes`, deployed if the `ipPrefix` parameter is set to 'yes' - https://docs.microsoft.com/en-us/azure/virtual-network/public-ip-address-prefix. 

* changed declarations:
  - Added the Public IP prefix resource to the `dependsOn` property on all Public IP addresses.
  - Added the `publicIPPrefix` property to all Public IP address resources with an if statement to set the value to variable `publicIPPrefixProperty` if the `ipPrefix` parameter is set to 'yes'
  - Changed the default value of the `_artifactsLocation` parameter to point to this GitHub Repo to allow the template to be deployed outside of the marketplace.

## How to deploy the template:

Local deployment: download this template and parameter file, edit the parameters and run your deployment tool of choice, e. g.

```
az group deployment create -g <existing-resource-group-name> --template-file ha-publicipprefix.json --parameters @ha-publicipprefix-parameters.json
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
It might be useful to include also a ssh public key in the parameters section of the ha-publicipprefix-parameters.json file.

## To deploy the ARM templates manually without using the Azure Marketplace:
1. Log in to the [Microsoft Azure Portal](https://portal.azure.com)
2. Click "*Create a resource*"
3. Search for "*Template deployment (deploy using custom templates)*" and click "*Create*"
4. Click "*Build your own template in the editor*"
5. Load the "*ha-publicipprefix.json*" file of the desired template and click "*Save*"
6. Enter the required and/or optional template parameters
7. Click *Purchase* to deploy the solution
8. Debug the deployment
