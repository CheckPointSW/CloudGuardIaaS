#! /bin/bash

#External Application gateway subnet address, for example 10.1.2.0/24
EXTERNAL_AGW_SUBNET_CIDR=<>

#VMSS frontend subnet default gateway.
#For each Azure subnet the IP Address x.x.x.1 is reserved for the default gateway
# https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#are-there-any-restrictions-on-using-ip-addresses-within-these-subnets
EXTERNAL_VMSS_SUBNET_DEFAULT_GATEWAY=<>

clish -c "set static-route $EXTERNAL_AGW_SUBNET_CIDR nexthop gateway address $EXTERNAL_VMSS_SUBNET_DEFAULT_GATEWAY on"