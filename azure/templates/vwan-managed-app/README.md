# Check Point CloudGuard Network Security for Azure Virtual WAN


Microsoft Azure Virtual WAN is a networking service that enables customers to easily establish optimized large-scale branch connectivity with Azure and the Microsoft global network, providing automated branch-to-branch connectivity.


## Image version
To retrieve the image version, perform an API GET call using the following URLs:

For Security Enforcement (NGTP) license:
```
https://management.azure.com/subscriptions/{subscription_id}/providers/Microsoft.Network/networkVirtualApplianceSkus/checkpoint?api-version=2023-05-01
```

For Full Package (NGTX + S1C) license:
```
https://management.azure.com/subscriptions/{subscription_id}/providers/Microsoft.Network/networkVirtualApplianceSkus/checkpoint-ngtx?api-version=2023-05-01
```

For Full Package Premium (NGTX + S1C++) license:
```
https://management.azure.com/subscriptions/{subscription_id}/providers/Microsoft.Network/networkVirtualApplianceSkus/checkpoint-premium?api-version=2023-05-01
```


## Output example:
```
{
  "etag": "00000000-0000-0000-0000-000000000000",
  "name": "checkpoint",
  "properties": {
    "availableScaleUnits": [
      {
        "instanceCount": "2",
        "scaleUnit": "10"
      },
      {
        "instanceCount": "2",
        "scaleUnit": "20"
      },
      {
        "instanceCount": "2",
        "scaleUnit": "2"
      },
      {
        "instanceCount": "3",
        "scaleUnit": "30"
      },
      {
        "instanceCount": "3",
        "scaleUnit": "40"
      },
      {
        "instanceCount": "2",
        "scaleUnit": "4"
      },
      {
        "instanceCount": "4",
        "scaleUnit": "60"
      },
      {
        "instanceCount": "5",
        "scaleUnit": "80"
      }
    ],
    "availableVersions": [
      "8110.900335.1435",
      "8120.900631.1433",
      "latest"
    ],
    "marketPlaceLink": "https://aka.ms/Checkpointmarketplace",
    "provisioningState": "Succeeded",
    "vendor": "checkpoint"
  }
}
```

From the output, extract the desired image from the "availableVersions" section (e.g., "8120.900631.1433")

Note: Do not use "latest"


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FCheckPointSW%2FCloudGuardIaaS%2Fmaster%2Fazure%2Ftemplates%2Fvwan-managed-app%2FmainTemplate.json">
 <img src="https://aka.ms/deploytoazurebutton" alt="Deploy to Azure" />
</a>
