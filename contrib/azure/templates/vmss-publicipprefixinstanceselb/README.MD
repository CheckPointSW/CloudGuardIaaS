# ARM CloudGuard IaaS Scale Set with instances' public IPs and external load balancer public IP allocated from an existing public IP prefix

This directory contains the CloudGuard IaaS VMSS template derived from the `vmss-v2` Check Point CloudGuard IaaS Scale Set Marketplace template version `20191003`.

This template adds the ability to allocate IP addresses for instances and for external load balancer from an existing public IP prefix - the public IP prefix for instances and for external load balancer could be the same or different, defined in the resource group allocated for VMSS or in a different resource group.

The VM scale set deployment was tested in the same existing resource group which includes the public IP prefix and public IP address for external load balancer.

## Changes from Marketplace template
* new parameters:
  * `mainTemplate.json`:
    - `existingPublicIPprefixGroupName`
    - `existingPublicIPprefixName`
    - `elbUsePublicIP`
    - `elbPublicIPAddressGroupName`
    - `elbPublicIPAddressName`
  * `load-balancers.json` nested template:
	- `elbUsePublicIP`
    - `elbPublicIPAddressId`
* new variables:
  *  `mainTemplate.json`:
    - `existingPublicIPaddressResID` : constructs the public IP prefix ID from the parameters declared above, ID to be referenced in `publicIPProperties` existing variable
  *  `load-balancers.json`:
    - `newAppAddressId`: automatically constructs external load balancer public IP if existing public IP is not used - previous declaration of `appAddressId` variable
	- `existingAppAddressId`: existing public IP address Id, referenced from resource group and public IP address names passed as parameters
* changed declarations:
  - `mainTemplate.json`: `publicIPProperties`
  - `load-balancers.json`: `appAddressId`: conditionally resolves the external load balancer public IP id based on utilization of existing public IP address
  - hardcoded main template URL in existing parameter `_artifactsLocation` referenced by `networkSetupURL` and `loadBalacerSetupURL` to locate the nested templates
  *Please verify and change accordingly to the raw github URI the `_artifactsLocation` value before deployment !*
  - removed `dependsOn: [variables('appAddressId')]` in `load-balancers.json` to allow reference to resorce not declared in template

## How to deploy the template:

Construct a parameters.json file and run your deployment tool of choice, e. g.

```
az group deployment create -g CPSM-OMV --template-uri https://raw.githubusercontent.com/CheckPointSW/CloudGuardIaaS/master/contrib/azure/templates/vmss-publicipprefixinstanceselb/mainTemplate.json --parameters @parameters.json --debug
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
Additional logic have to be implemented to select admin password source.