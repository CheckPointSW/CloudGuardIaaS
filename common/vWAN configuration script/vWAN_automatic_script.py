import sys
import json
import __init__ as init

import cloud_connectors.azure as azure
from cp_handlers.cpm_globals import IP_ADDRESS, INTERFACES, MASK_LENGTH,\
    ANTI_SPOOFING, TOPOLOGY, TOPOLOGY_SETTINGS, IP_ADDRESS_BEHIND_THIS_INTERFACE, \
    EXTERNAL, INTERNAL, CPMCommand, VERSION, POLICY_PACKAGE, TARGETS, CPMCommandType, PUBLIC_IP
from cme_globals import ETH0
from configuration.configuration_globals import ConfGlobal
from cp_handlers.mgmt_handler import Management
from configuration.conf_objects.azure_account import AzureAccount
from cloud_is.rest_infra.exceptions.rest_exceptions import BadParameterValueException
# For pyflakes
var = init

ETH0_PRIVATE_IP = 'eth0_private_ip'
ETH1_PRIVATE_IP = 'eth1_private_ip'
ETH1 = 'eth1'
UUID_FORMAT = 'string UUID format'
MANAGED_APP_RESOURCE_GROUP_NAME = 'managedAppResourceGroupName'
NVA_NAME = 'nvaName'
PROPERTIES = 'properties'
ADDRESS_PREFIX = 'addressPrefix'
CLOUD_INIT_CONFIGURATION = 'cloudInitConfiguration'
INSTANCE_NAME = 'instanceName'
PUBLIC_IP_FIELD = 'publicIpAddress'
PRIVATE_IP_FIELD = 'privateIpAddress'
SET_PACKAGE = 'set-package'
RESOURCE = 'resource'
VIRTUAL_APPLIANCE_NIC = 'virtualApplianceNics'


def init_variables():
    """
    This function initializes the necessary variables for runnig the script
    and creates a credentials dictionary for connecting to Azure.
    """
    if len(sys.argv) == 1:
        sys.exit('Invalid number of command line arguments.')
    var_list = sys.argv[1:]
    var_list_without_new_line = [x.replace('\n', '') for x in var_list]
    global vars
    vars = {}
    uuid_items = [ConfGlobal.TENANT, ConfGlobal.CLIENT_ID, ConfGlobal.SUBSCRIPTION]
    for var in var_list_without_new_line:
        try:
            if "=" not in var:
                sys.exit('Invalid variable - {} , "=" is missing'.format(var))
            key, val = str(var).split("=")
            if not key or not val:
                sys.exit('Invalid variable - {}, missing {}'.format(var, 'key' if not key else 'value'))

            if key.strip() in uuid_items:
                if not AzureAccount.is_guid_uuid(str(val.strip())):
                    raise BadParameterValueException(key, val, UUID_FORMAT)

            vars[key.strip()] = val[0:].rstrip()

        except Exception as e:
            sys.exit('Failed to parse the variable {}.\nError info: {}'.format(var, e))

    global CREDENTIALS
    CREDENTIALS = {
        ConfGlobal.GRANT_TYPE: ConfGlobal.CLIENT_CREDENTIALS,
        ConfGlobal.CLIENT_ID: vars.get(ConfGlobal.CLIENT_ID),
        ConfGlobal.CLIENT_SECRET: vars.get(ConfGlobal.CLIENT_SECRET),
        ConfGlobal.TENANT: vars.get(ConfGlobal.TENANT),
        RESOURCE: 'https://management.azure.com/'
    }


def get_data_from_azure() -> json:
    """
    "This function makes an API call to Azure to retrieve all the necessary data for configuring the NVA gateway.
    :return: Data from API call to Azure
    """
    try:
        azure_obj = azure.Azure(subscription=vars.get(ConfGlobal.SUBSCRIPTION), credentials=CREDENTIALS)
        path = "/resourceGroups/{}/providers/Microsoft.Network/networkVirtualAppliances/{}?api-version=2022-07-01".format(
            vars.get(MANAGED_APP_RESOURCE_GROUP_NAME), vars.get(NVA_NAME))
        headres, body = azure_obj.arm('GET', path)
        return body
    except Exception as e:
        sys.exit('Failed to get gateways from NVA {}. Error info: {}'.format(vars.get(NVA_NAME), e))


def get_mask_length(data):
    """
    This function retrieves the mask length.
    :param data: All the data regarding the gateway that we got from Azure
    :return: Mask length
    """
    return data[PROPERTIES][ADDRESS_PREFIX].split("/")[-1]


def get_version(data):
    """
    This function retrieves the gateway version.
    :param data: All the data regarding the gateway that we got from Azure
    :return: Gateway version
    """
    try:
        all_data = data[PROPERTIES][CLOUD_INIT_CONFIGURATION]
        for line in all_data.split('\n'):
            if line.startswith('osVersion'):
                start_index = line.find('"')
                version = line[start_index+1: -1]
                return version[:3] + "." + version[3:]
    except Exception as e:
        sys.exit('Failed to get gateways version {}. Error info: {}'.format(vars.get(NVA_NAME), e))


def get_gateways_info(gateways) -> dict:
    """
    This function return dictionary with gateways where each item has a aname, public IP and two private IPs
    :param gateways: Dictionary with gateways as returned from Azure (each gateway name appears twice)
    :return: Gateways dictionary
    """
    try:
        gateways_dict = {}
        for gw in gateways:
            name = gw.get(INSTANCE_NAME)
            public_ip = gw.get(PUBLIC_IP_FIELD)
            private_ip = gw.get(PRIVATE_IP_FIELD)
            if name not in gateways_dict:
                gateways_dict[name] = {
                    PUBLIC_IP: '',
                    ETH0_PRIVATE_IP: '',
                    ETH1_PRIVATE_IP: ''
                }
            if not public_ip:
                gateways_dict[name][ETH1_PRIVATE_IP] = private_ip
            else:
                gateways_dict[name][PUBLIC_IP] = public_ip
                gateways_dict[name][ETH0_PRIVATE_IP] = private_ip
        return gateways_dict.items()
    except Exception:
        sys.exit('Failed to parse gateways')


def create_mgmt_obj() -> object:
    """
    This function creates a Management object for making Management
    API calls to configure the gateways on Smart Console
    :return: Management object
    """
    session_name = 'vWAN_CME'
    options = {ConfGlobal.DOMAIN: None, ConfGlobal.HOST: ConfGlobal.LOCAL_HOST, ConfGlobal.NAME: session_name}
    return Management(session_name, **options)


def get_interfaces_for_mgmt_api(
        name, ip_address, mask_length, anti_apoofing, topology, ip_address_behind_this_interface=None) -> dict:
    """
    This function generates a dictionary of interfaces that used to configure the gateway
    :param name: Interface name
    :param ip_address: Interface IP address
    :param mask_length: Mask length
    :param anti_apoofing: True/false - enable or disable anti-spoofing
    :param topology: Interface topology
    :param ip_address_behind_this_interface: Network settings behind this interface
    :return: Interface dictionary
    """
    interace = {
        ConfGlobal.NAME: name,
        IP_ADDRESS: ip_address,
        MASK_LENGTH: mask_length,
        ANTI_SPOOFING: anti_apoofing,
        TOPOLOGY: topology,
    }

    if ip_address_behind_this_interface:
        interace[TOPOLOGY_SETTINGS] = {
            IP_ADDRESS_BEHIND_THIS_INTERFACE: ip_address_behind_this_interface
        }
    return interace


def configure_gateway_data(gw_info, data) -> dict:
    """
    This function generates a gateway dictionary with all the info to configure it
    :param gw_info: Gateway dictionary with name, public and private IP address
    :param data: All the data regarding the gateway that we got from Azure
    :return: Gateway dictionary
    """
    mask_length = get_mask_length(data)
    version = get_version(data)
    gw = {
        ConfGlobal.NAME: gw_info[0],
        IP_ADDRESS: gw_info[1][PUBLIC_IP],
        ConfGlobal.ONE_TIME_PASSWORD: vars[ConfGlobal.SIC],
        VERSION: version,
        INTERFACES: [
            get_interfaces_for_mgmt_api(ETH0, gw_info[1][ETH0_PRIVATE_IP], mask_length, False, EXTERNAL),
            get_interfaces_for_mgmt_api(
                ETH1, gw_info[1][ETH1_PRIVATE_IP],
                mask_length, False, INTERNAL, 'network defined by routing')
        ]
    }
    return gw


def add_gateway_to_cpm(gw_info, data, mgmt_object):
    """
    This function adds the gateway to Smart Console
    :param gw_info: Gateway dictionary with name, public and private IP address
    :param data: All the data regarding the gateway that we got from Azure
    :param mgmt_object: Management object for making Management API calls
    """
    gw = configure_gateway_data(gw_info, data)
    try:
        mgmt_object(CPMCommand.ADD_SIMPLE_GATEWAY, gw)
    except Exception as e:
        sys.exit('Failed to add gateway {} to Smart Console. Error info: {}'.format(gw_info[0], e))


def set_policy(policy_name, policy_targets, mgmt_object):
    """
    This function adds gateways that are configured in the Smart Console to the desired policy
    :param policy_name: Policy name
    :param policy_targets: Gateways to add to the policy
    :param mgmt_object: Management object for making Management API calls
    """
    mgmt_object(SET_PACKAGE, {
        ConfGlobal.NAME: policy_name,
        'installation-targets': {CPMCommandType.ADD: policy_targets}
    })


def install_policy(policy_name, policy_targets, mgmt_object):
    """
    This function installing the policy
    :param policy_name: Policy name
    :param policy_targets: Gateways to install to the policy on
    :param mgmt_object: Management object for making Management API calls
    """
    mgmt_object(CPMCommand.INSTALL_POLICY, {
        POLICY_PACKAGE: policy_name,
        TARGETS: policy_targets
    })


def provision_gateway(policy_targets, mgmt_object):
    """
    This function provision the gateways - publish, add gateways to the policy, and install the policy
    :param policy_targets: Gateways to provision
    :param mgmt_object: Management object for making Management API calls
    """
    sys.stdout.write('Starting to provision the gateways, it may take a few minutes, please don\'t close this window. \n')
    try:
        mgmt_object(CPMCommand.PUBLISH, {})
        set_policy(vars[ConfGlobal.POLICY], policy_targets, mgmt_object)
        install_policy(vars[ConfGlobal.POLICY], policy_targets, mgmt_object)
        sys.stdout.write('Succeeded to provision all the gateways \n')
    except Exception as e:
        sys.exit('Failed to provision gateways. Error info: {}'.format(e))


init_variables()
data = get_data_from_azure()
gateways = get_gateways_info(data[PROPERTIES][VIRTUAL_APPLIANCE_NIC])
sys.stdout.write('Starting to configure these gateways: \n')
for gw in gateways:
    sys.stdout.write('{} - {} \n'.format(gw[0], gw[1][PUBLIC_IP]))
mgmt_vWAN = create_mgmt_obj()
policy_targets = []
for gw in gateways:
    add_gateway_to_cpm(gw, data, mgmt_vWAN)
    sys.stdout.write('Succeeded to add {} - {} to Smart Console \n'.format(gw[0], gw[1][PUBLIC_IP]))
    policy_targets.append(gw[0])
provision_gateway(policy_targets, mgmt_vWAN)
