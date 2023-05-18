# Postman Collection for Azure Virtual Network Management

This Postman collection provides a set of APIs for managing Azure Virtual Network resources. The collection includes the following categories:

## Virtual WANs

- **GET All Virtual Wans in resourceGroup**: Retrieves a list of all virtual WANs in a specified resource group.
- **GET All Virtual Wans in subscription**: Retrieves a list of all virtual WANs in a specified subscription.
- **GET Virtual Wan**: Retrieves details of a specific virtual WAN.
- **DEL Virtual Wan**: Deletes a specific virtual WAN.
- **PATCH Update Tags for vWAN**: Updates the tags for a specific virtual WAN.
- **PUT Virtual Wan**: Creates or updates a virtual WAN.

## Virtual Hubs
- **GET Virtual Hub**: Retrieves details of a specific virtual hub.
- **PUT Virtual Hub - Create Or Update**: Creates or updates a virtual hub.
- **GET All Virtual Hubs in resourceGroup**: Retrieves a list of all virtual hubs in a specified resource group.
- **GET All Virtual Hubs in subscription**: Retrieves a list of all virtual hubs in a specified subscription.
- **PATCH Update Tags for vHub**: Updates the tags for a specific virtual hub.
### Hub Route Tables

- **GET Route Table**: Retrieves details of a specific route table associated with a virtual hub.
- **PUT Route Table - Create Or Update**: Creates or updates a route table associated with a virtual hub.
- **DEL Route Table**: Deletes a specific route table associated with a virtual hub.
- **GET All Route Tables**: Retrieves a list of all route tables associated with a virtual hub.

### Hub Virtual Network Connections

- **GET Virtual Network Connections**: Retrieves details of a specific virtual network connection associated with a virtual hub.
- **PUT Virtual Network Connections - Create Or Update**: Creates or updates a virtual network connection associated with a virtual hub.
- **DEL Virtual Network Connections**: Deletes a specific virtual network connection associated with a virtual hub.
- **GET All Virtual Network Connections**: Retrieves a list of all virtual network connections associated with a virtual hub.

- **POST Effective Routes**: Creates or updates a ExpressRoute gateway in a specified resource group.

## Routing Intent

- **PUT Routing Intent**: Creates or updates a routing intent for a specific virtual hub.
- **GET Routing Intent**: Retrieves the routing intent for a specific virtual hub.
- **DEL Routing Intent**: Deletes a specific routing intent for a specific virtual hub.

## VPN Sites

- **GET VPN Site**: Retrieves details of a specific VPN site.
- **GET All VPN Sites in resourceGroup**: Retrieves a list of all VPN sites in a specified resource group.
- **GET All VPN Sites in subscription**: Retrieves a list of all VPN sites in a specified subscription.

## Network Virtual Appliance (NVA)

- **DEL NVA**: Deletes a specific Network Virtual Appliance.
- **GET NVA**: Retrieves details of a specific Network Virtual Appliance.
- **GET All NVAs**: Retrieves a list of all Network Virtual Appliances in a resource group.

## Security Rule

- **PUT Inbound Security Rule - Create Or Update**: Creates or updates an inbound security rule.

## Usage

To use this collection, you will need to set up a Virtual Network environment and have the appropriate credentials in your subscription to manage Virtual Network resources. You will also need to import the collection into Postman and configure the variables in the collection with your Azure credentials.

Once you have configured the environment variables, you can use the collection to manage your Virtual Network resources.

## Contributing

If you find any issues with this collection or would like to suggest an improvement, please feel free to open an issue or submit a pull request. We welcome contributions from the community!