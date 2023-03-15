import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
import time
import json
import sys

MGMT_IP_INPUT = 'mgmt_ip'
TENANT_ID_INPUT = 'tenant_id'
CLIENT_ID_INPUT = 'client_id'
CLIENT_SECRET_INPUT = 'client_secret'
SUBSCRIPTION_ID_INPUT = 'subscription_id'
MANAGED_APP_RESOURCE_GROUP_NAME_INPUT = 'managed_app_resource_group_name'
NVA_NAME_INPUT = 'nva_name'
USER_NAME_INPUT = 'user_name'
POLICY_INPUT = 'policy_name'
PASSWORD = 'password'
INSTANCE_NAME = 'instanceName'
GRANT_TYPE = 'grant_type'
PROPERTIES = 'properties'
ADDRESS_PREFIX = 'addressPrefix'
IPV4_ADDRESS = 'ipv4-address'
ONE_TIME_PASSWORD = 'one-time-password'
IPV4_MASK_LENGTH = 'ipv4-mask-length'
ANTI_SPOOFING = 'anti-spoofing'
TOPOLOGY = 'topology'
INTERFACES = 'interfaces'
TOPOLOGY_SETTINGS = 'topology-settings'
IP_ADDRESS_BEHIND_THIS_INTERFACE = 'ip-address-behind-this-interface'
TASK_ID = 'task-id'
VIRTUAL_APPLIANCE_NIC = 'virtualApplianceNics'
NAME = 'name'
USER = 'user'
RESOURCE = 'resource'
CONTENT_TYPE = 'Content-Type'
CONTENT_TYPE_VAL = 'application/json'
X_CHKP_SID = 'X-chkp-sid'
PUBLIC_IP_FIELD = 'publicIpAddress'
PRIVATE_IP_FIELD = 'privateIpAddress'
STANDARD = 'standard'
SUCCESS_STATUS = 'succeeded'
FAIL_STATUS = 'failed'


def init_variables_from_config():
    with open('vWAN_automation_config.json', 'r') as config:
        config_json = json.load(config)
        global MGMT_URL
        MGMT_URL = 'https://' + config_json[MGMT_IP_INPUT] + '/web_api'
        global MGMT_IP
        MGMT_IP = config_json[MGMT_IP_INPUT]
        global TENANT_ID
        TENANT_ID = config_json[TENANT_ID_INPUT]
        global CLIENT_ID
        CLIENT_ID = config_json[CLIENT_ID_INPUT]
        global CLIENT_SECRET
        CLIENT_SECRET = input('Please enter client secret for this {} client ID: '.format(CLIENT_ID))
        global SUBSCRIPTION_ID
        SUBSCRIPTION_ID = config_json[SUBSCRIPTION_ID_INPUT]
        global MANAGED_APP_RESOURCE_GROUP_NAME
        MANAGED_APP_RESOURCE_GROUP_NAME = config_json[MANAGED_APP_RESOURCE_GROUP_NAME_INPUT]
        global NVA_NAME
        NVA_NAME = config_json[NVA_NAME_INPUT]
        global USER_NAME
        USER_NAME = config_json[USER_NAME_INPUT]
        global PWD
        PWD = config_json[PASSWORD]
        global SIC
        SIC = input('Please enter SIC key: ')
        global POLICY
        POLICY = config_json[POLICY_INPUT]


def mgmt_login():
    print('Logging in to management')
    url = f'{MGMT_URL}/v1.8/login'
    headers = {
        CONTENT_TYPE: CONTENT_TYPE_VAL
    }
    body = {
        USER: USER_NAME,
        PASSWORD: PWD
    }

    try:
        res = requests.post(url, json=body, headers=headers, verify=False)
        return res.json()['sid']
    except Exception:
        sys.exit('Failed to login to managament {}'.format(MGMT_IP))


def get_access_token():
    url = f'https://login.microsoftonline.com/{TENANT_ID}/oauth2/token'
    body = {
        GRANT_TYPE: 'client_credentials',
        CLIENT_ID_INPUT: CLIENT_ID,
        CLIENT_SECRET_INPUT: CLIENT_SECRET,
        RESOURCE: 'https://management.azure.com/'
    }
    res = requests.post(url, body)
    return res.json()['access_token']


def get_nva_gateways():
    print('Getting gateways from NVA {}'.format(NVA_NAME))
    try:
        access_token = get_access_token()
        url = f'https://management.azure.com/subscriptions/{SUBSCRIPTION_ID}/resourceGroups/{MANAGED_APP_RESOURCE_GROUP_NAME}/providers/Microsoft.Network/networkVirtualAppliances/{NVA_NAME}?api-version=2022-07-01'
        headers = {
            'Authorization': f'Bearer {access_token}'
        }

        res = requests.get(url, headers=headers, verify=False)
        global IPV4_MASK_LENGTH_VAL
        IPV4_MASK_LENGTH_VAL = res.json()[PROPERTIES][ADDRESS_PREFIX].split("/")[-1]
        return res.json()[PROPERTIES][VIRTUAL_APPLIANCE_NIC]

    except Exception:
        sys.exit('Failed to get gateways from NVA {}'.format(NVA_NAME))


def gateways_info_generator(gateways):
    gateways_dict = {}
    for gw in gateways:
        gw_name = gw[INSTANCE_NAME]
        gw_dict = gateways_dict.setdefault(gw_name, {NAME: gw_name, PUBLIC_IP_FIELD: '', PRIVATE_IP_FIELD: []})
        if gw[PUBLIC_IP_FIELD]:
            gw_dict[PUBLIC_IP_FIELD] = gw[PUBLIC_IP_FIELD]
        gw_dict[PRIVATE_IP_FIELD].append(gw[PRIVATE_IP_FIELD])

    for gw_ret in gateways_dict.values():
        if len(gw_ret[PRIVATE_IP_FIELD]) == 2:
            yield gw_ret


def get_headers_for_mgmt_api():
    headers = {
        CONTENT_TYPE: CONTENT_TYPE_VAL,
        X_CHKP_SID: SID
    }

    return headers


def get_interfaces_for_mgmt_api(
        name, ipv4_address, ipv4_mask_length, anti_apoofing, topology, ip_address_behind_this_interface=None):
    interace = {
        NAME: name,
        IPV4_ADDRESS: ipv4_address,
        IPV4_MASK_LENGTH: ipv4_mask_length,
        ANTI_SPOOFING: anti_apoofing,
        TOPOLOGY: topology,
    }

    if ip_address_behind_this_interface:
        interace[TOPOLOGY_SETTINGS] = {
            IP_ADDRESS_BEHIND_THIS_INTERFACE: ip_address_behind_this_interface
        }

    return interace


def configure_gw_in_mgmt(gw):
    url = f'{MGMT_URL}/add-simple-gateway'
    headers = get_headers_for_mgmt_api()
    body = {
        NAME: gw[NAME],
        IPV4_ADDRESS: gw[PUBLIC_IP_FIELD],
        ONE_TIME_PASSWORD: SIC,
        INTERFACES: [
            get_interfaces_for_mgmt_api('eth0', gw[PRIVATE_IP_FIELD][1], IPV4_MASK_LENGTH_VAL, False, 'external'),
            get_interfaces_for_mgmt_api(
                'eth1', gw[PRIVATE_IP_FIELD][0], IPV4_MASK_LENGTH_VAL, False, 'internal', 'network defined by routing')
        ]
    }

    try:
        res = requests.post(url, json=body, headers=headers, verify=False)

    except Exception:
        sys.exit('Failed to configure gateway {} on management.'.format(gw[NAME]))


def mgmt_publish():
    print('Starting publish operation')
    url = f'{MGMT_URL}/publish'
    headers = get_headers_for_mgmt_api()
    try:
        res = requests.post(url, json={}, headers=headers, verify=False)
    except Exception:
        sys.exit('Failed to publish.')
    task_id = res.json()[TASK_ID]
    print('Checking publish status result, please don\'t close this window.')
    while query_mgmt_task_completion(task_id) == 0:
        time.sleep(2)
    print('{} to publish.'.format('Succeed' if query_mgmt_task_completion(task_id) == 1 else 'Failed'))


def mgmt_add_gateways_to_policy(policy_targets):
    print('Starting to add gateways to policy installation targets')
    url = f'{MGMT_URL}/set-package'
    headers = get_headers_for_mgmt_api()
    body = {
        NAME: POLICY,
        'installation-targets': policy_targets
    }

    try:
        res = requests.post(url, json=body, headers=headers, verify=False)
        print('Policy targets have been added')
    except Exception:
        sys.exit('Failed to add gateways to policy installation targets')


def mgmt_install_policy():
    print('Installing policy {}'.format(POLICY))
    url = f'{MGMT_URL}/install-policy'
    headers = get_headers_for_mgmt_api()
    body = {
        'policy-package': POLICY
    }

    try:
        res = requests.post(url, json=body, headers=headers, verify=False)
    except Exception:
        print('Failed to install policy on gateways.')
    task_id = res.json()[TASK_ID]
    print('Checking install policy status result, please don\'t close this window.')
    while query_mgmt_task_completion(task_id) == 0:
        time.sleep(2)
    print('{} to install policy {} on gateways.'.format(
        'Succeed' if query_mgmt_task_completion(task_id) == 1 else 'Failed', POLICY))


def query_mgmt_task_completion(task_id):
    url = f'{MGMT_URL}/show-task'
    headers = get_headers_for_mgmt_api()
    body = {
        TASK_ID: task_id
    }

    try:
        res = requests.post(url, json=body, headers=headers, verify=False)
    except Exception:
        sys.exit('Failed to configure gateways on management.')
    task_status = res.json()['tasks'][0]['status']
    return 1 if task_status == SUCCESS_STATUS else -1 if task_status == FAIL_STATUS else 0


requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

init_variables_from_config()
SID = mgmt_login()
_gateways = get_nva_gateways()
_policy_targets = []
for gw_info in gateways_info_generator(_gateways):
    print('Starting to configure {} - {}'.format(gw_info[NAME], gw_info[PUBLIC_IP_FIELD]))
    configure_gw_in_mgmt(gw_info)
    print('Succeeded to configure {} - {}'.format(gw_info[NAME], gw_info[PUBLIC_IP_FIELD]))
    _policy_targets.append(gw_info[NAME])
mgmt_add_gateways_to_policy(_policy_targets)
mgmt_publish()
mgmt_install_policy()
