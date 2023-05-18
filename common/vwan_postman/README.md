# Postman Collection for Azure Virtual WAN Management

This Postman collection provides a set of APIs for managing Azure Virtual WAN resources. The collection includes the following categories:

## Virtual WANs

- **GET All virtualWans in resourceGroup**: Retrieve all Virtual WANs in a resource group.
- **GET All virtualWans in subscription**: Retrieve all Virtual WANs in a subscription.
- **GET virtualWan**: Retrieve details of a specific Virtual WAN.

## Virtual Hubs

- **GET virtualHub**: Retrieve details of a specific Virtual Hub.
- **DEL Delete virtualHub**: Delete a specific Virtual Hub.
- **POST Effective Routes**: Creates or updates a ExpressRoute gateway in a specified resource group.  
- **GET All virtualHubs in resourceGroup**: Retrieve all Virtual Hubs in a resource group.
- **GET All virtualHubs in subscription**: Retrieve all Virtual Hubs in a subscription.
- **PUT Routing Intent**: Update the routing intent for a specific Virtual Hub.
- **GET Routing Intent**: Retrieve the routing intent for a specific Virtual Hub.

## VPN Sites

- **GET vpnSite**: Retrieve details of a specific VPN site.
- **GET All vpnSite in resourceGroup**: Retrieve all VPN sites in a resource group.
- **GET All vpnSite in subscription**: Retrieve all VPN sites in a subscription.

## NVA

- **DEL NetworkVirtualAppliance**: Delete a specific Network Virtual Appliance.
- **GET NetworkVirtualAppliance**: Retrieve details of a specific Network Virtual Appliance.
- **GET All NetworkVirtualAppliances**: Retrieve all Network Virtual Appliances in a resource group.
- **GET All NetworkVirtualAppliances Subscription**: Retrieve all Network Virtual Appliances in a subscription.
- **GET Get Onboarded Images**: Retrieve a list of onboarded images for a Network Virtual Appliance.

## Usage

To use this collection, you will need to set up a Virtual WAN environment and  have the appropriate credentials in your subscription to manage Virtual WAN resources. You will also need to import the collection into Postman and configure the variables in the collection with your Azure credentials.

Once you have configured the environment variables, you can use the collection to manage your Virtual WAN resources.

## Contributing

If you find any issues with this collection or would like to suggest an improvement, please feel free to open an issue or submit a pull request. We welcome contributions from the community!