#!/usr/bin/env python3
import contextlib
import json
import os
import re
import socket
import subprocess
import sys
import traceback
import collections
import urllib.parse as _urllib


try:
    import rest
except ModuleNotFoundError:
    import pytest
    pytestmark = pytest.mark.skipif(True, reason="Needs refactoring - WIP")
    import cloud_connectors.azure as rest

ARM_VERSIONS = {
    'stack': collections.OrderedDict([
        ('resources', '?api-version=2017-10-01'),
    ]),
    'ha': collections.OrderedDict([
        ('resources', '?api-version=2019-07-01'),
    ])}

os.environ['AZURE_NO_DOT'] = 'true'

azure = None
templateName = None

conf = {}


def set_arm_versions():
    global ARM_VERSIONS
    log('Setting api versions for "%s" solution\n' % templateName)
    if templateName == 'stack-ha':
        ARM_VERSIONS = ARM_VERSIONS['stack']
        log('Stack ARM versions are: %s\n' % json.dumps(ARM_VERSIONS,
                                                        indent=2))
        return
    ARM_VERSIONS = ARM_VERSIONS['ha']
    log('ARM versions are: %s\n' % json.dumps(ARM_VERSIONS, indent=2))


def is_azure():
    return os.path.isfile('/etc/in-azure')


def log(msg):
    sys.stderr.write(msg)


def test_rw(rid, allow_not_found=False, test_write=True):
    components = rid.split('/')
    log('Id            : %s\n' % rid)
    log('Subscription  : %s\n' % components[2])
    log('Resource group: %s\n' % components[4])
    log('Type          : %s/%s\n' % (components[6], components[7]))
    log('Name          : %s\n' % components[8])
    try:
        obj = azure.arm('GET', rid + ARM_VERSIONS['resources'])[1]
    except rest.RequestException as e:
        if allow_not_found and e.code == 404:
            return None
        log('Attempting to read - [%s]\n' % e.reason)
        raise
    log('Attempting to read - [OK]\n')
    if test_write:
        log('Attempting to write ')
        try:
            azure.arm('PUT', rid + ARM_VERSIONS['resources'], json.dumps(obj))
        except rest.RequestException as e:
            log('- [%s]\n' % e.reason)
            raise
        log('- [OK]\n')
    return obj


def get_vm_primary_nic(vm):
    nis = vm['properties']['networkProfile']['networkInterfaces']
    if len(nis) == 1:
        ni = nis[0]
    else:
        for ni in nis:
            if ni['properties'].get('primary'):
                break
    return azure.arm('GET', ni['id'])[1]


def test_cluster_ip():
    def test_vip(vip_resource):
        if '/' in vip_resource:
            cluster_ip_id = vip_resource
        else:
            cluster_ip_id = conf['baseId'] + \
                'Microsoft.Network/publicIPAddresses/' + vip_resource
        test_rw(cluster_ip_id, allow_not_found=True, test_write=False)

    for interface in conf['clusterNetworkInterfaces']:
        if isinstance(conf['clusterNetworkInterfaces'][interface][0], dict):
            for vip in conf['clusterNetworkInterfaces'][interface]:
                test_vip(vip["pub"])
        else:
            if len(conf['clusterNetworkInterfaces'][interface]) > 1:
                test_vip(conf['clusterNetworkInterfaces'][interface][1])


def test_load_balancer():
    load_balancer_nm = conf.get('lbName', '')
    if not load_balancer_nm:
        log('An external load balancer name is not configured.\n')
        return None

    load_balancer_id = (conf['baseId'] +
                        'Microsoft.Network/loadBalancers/' +
                        load_balancer_nm)
    test_rw(load_balancer_id, allow_not_found=True)


def vnet_rg():
    local_vm = azure.arm('GET', conf['baseId'] +
                         'microsoft.compute/virtualmachines/' +
                         conf['hostname'])[1]
    my_nic = get_vm_primary_nic(local_vm)
    subnet_id = my_nic['properties']['ipConfigurations'][0][
        'properties']['subnet']['id']
    return '/'.join(subnet_id.split('/')[:5])


def get_route_table_ids_for_vnet(vnet):
    route_table_ids = set()
    for subnet in vnet['properties'].get('subnets', []):
        if subnet['properties'].get('routeTable'):
            route_table_ids.add(subnet['properties']['routeTable']['id'])
    return route_table_ids


def get_vnet_id():
    vnet_id = conf.get('vnetId')
    if vnet_id:
        return vnet_id
    me = azure.arm('GET', conf['baseId'] +
                   'microsoft.compute/virtualmachines/' + conf['hostname'])[1]
    my_nic = get_vm_primary_nic(me)
    subnet_id = my_nic['properties']['ipConfigurations'][0][
        'properties']['subnet']['id']
    vnet_id = '/'.join(subnet_id.split('/')[:-2])
    conf['vnetId'] = vnet_id
    return vnet_id


def get_route_table_ids_for_peering(vnet):
    route_table_ids = set()

    for peering in vnet['properties'].get('virtualNetworkPeerings', []):
        vnet_id = peering['properties']['remoteVirtualNetwork']['id']
        state = peering['properties']['peeringState']
        if state != 'Connected':
            log('peered vnet %s in state %s ignored' % (vnet_id, state))
            continue
        try:
            vnet = azure.arm('GET', vnet_id)[1]
        except Exception:
            log('\nFailed to retrieve peered network %s' % vnet_id)
            log('\n%s' % traceback.format_exc())
            continue
        route_table_ids |= get_route_table_ids_for_vnet(vnet)

    return route_table_ids


def get_route_table_ids():
    route_table_ids = set()

    vnet_id = get_vnet_id()
    vnet = azure.arm('GET', vnet_id)[1]

    route_table_ids |= get_route_table_ids_for_vnet(vnet)
    route_table_ids |= get_route_table_ids_for_peering(vnet)

    return route_table_ids


def interfaces_test_rw(interface_id):
    interface = test_rw(interface_id['id'])
    if not interface['properties'].get('enableIPForwarding'):
        raise Exception(
            'IP forwarding is not enabled on Interface %s' %
            interface['name'])


def test_cluster_parameters():
    path = "/var/opt/fw.boot/modules/fwkern.conf"
    text1 = "fwha_dead_timeout_multiplier=20"
    text2 = "fwha_if_problem_tolerance=200"
    flags = dict.fromkeys(["fwkern_timeout_multiplier",
                           "fwkern_problem_tolerance",
                           "output_timeout_multiplier",
                           "output_problem_tolerance"],
                          False)
    error = 'ClusterXL kernel parameters are not optimized for ' \
            'Azure. See sk122218 for more information.'

    with open(path) as f:
        for line in f:
            if text1 in line:
                flags['fwkern_timeout_multiplier'] = True
            if text2 in line:
                flags['fwkern_problem_tolerance'] = True

        command = ['fw', 'ctl', 'get', 'int', 'fwha_dead_timeout_multiplier']
        proc = subprocess.Popen(
            command, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
        out, err = proc.communicate()
        if out.decode('utf-8').strip() == 'fwha_dead_timeout_multiplier = 20':
            flags['output_timeout_multiplier'] = True

        command = ['fw', 'ctl', 'get', 'int', 'fwha_if_problem_tolerance']
        proc = subprocess.Popen(
            command, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
        out, err = proc.communicate()

        if out.decode('utf-8').strip() == 'fwha_if_problem_tolerance = 200':
            flags['output_problem_tolerance'] = True

        if not all(value is True for value in list(flags.values())):
            raise Exception(error)


def test():
    global conf

    if not is_azure():
        raise Exception('This does not look like an Azure environment\n')

    command = [os.environ['FWDIR'] + '/bin/azure-ha-conf', '--dump']
    proc = subprocess.Popen(
        command, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    out, err = proc.communicate()
    rc = proc.wait()
    if rc:
        log('\nfailed to run %s: %s\n%s' % (command, rc, err))
        raise Exception('Failed to load configuration file\n')
    conf = json.loads(out)

    for k in ['clusterName', 'resourceGroup', 'subscriptionId']:
        if not conf.get(k):
            raise Exception(
                'The attribute %s is missing in the configuration' % k)

    proxy = conf.get('proxy', '')
    os.environ['https_proxy'] = proxy
    os.environ['http_proxy'] = proxy

    credentials = conf.get('credentials')
    if credentials:
        pass
    elif conf.get('password') and conf.get('userName'):
        credentials = {
            'username': conf['userName'],
            'password': conf['password']}
    else:
        raise Exception('Missing credentials')

    environment = conf.get('environment')

    global azure, templateName
    azure = rest.Azure(credentials=credentials,
                       subscription=conf['subscriptionId'],
                       max_time=20,
                       environment=environment)

    templateName = conf.get('templateName', '').lower()
    set_arm_versions()

    conf['hostname'] = conf.get('hostname', socket.gethostname())
    cluster_name = conf['clusterName'].lower()
    if conf['hostname'] not in {cluster_name + '1', cluster_name + '2'}:
        raise Exception('The hostname %s should be either \'%s\' or \'%s\'' % (
            conf['hostname'], cluster_name + '1', cluster_name + '2'))

    if 'peername' not in conf:
        if conf['hostname'].endswith('1'):
            conf['peername'] = conf['hostname'][:-1] + '2'
        else:
            conf['peername'] = conf['hostname'][:-1] + '1'

    conf['rg_id'] = ('/subscriptions/' + conf['subscriptionId'] +
                     '/resourcegroups/' + conf['resourceGroup'])

    conf['baseId'] = conf['rg_id'] + '/providers/'

    log('Testing if DNS is configured...\n')
    try:
        dns = subprocess.check_output(
            ['/bin/clish', '-c', 'show dns primary']).decode('utf-8').strip()
    except Exception:
        traceback.print_exc()
        raise
    match = re.search(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})', dns)
    if not match:
        raise Exception('Primary DNS server is not configured\n')
    log(' - Primary DNS server is: %s\n' % match.group(1))

    log('Testing if DNS is working...\n')
    if proxy:
        host = _urllib.urlparse(proxy).hostname
        if host is None:
            raise Exception('Failed to get hostname from proxy: %s\n' % proxy)

        port = _urllib.urlparse(proxy).port
        if not port:
            if _urllib.urlparse(proxy).scheme == 'https':
                port = 443
            else:
                port = 80
    else:
        host = azure.environment.login
        port = 443
    try:
        socket.gethostbyname(host)
        log(' - DNS resolving test was successful\n')
    except Exception:
        raise Exception('Failed to resolve %s\n' % host)

    log('Testing connectivity to %s:%d...\n' % (host, port))
    with contextlib.closing(
            socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as s:
        s.settimeout(3)
        if s.connect_ex((host, port)):
            raise Exception('Unable to connect to %s:%d\n' % (host, port))

    log('Testing ClusterXL parameters...\n')
    test_cluster_parameters()

    log('Testing cluster interface configuration...\n')
    try:
        cphaconf = json.loads(
            subprocess.check_output(['cphaconf', 'aws_mode']))
    except Exception:
        raise Exception('''You do not seem to have a valid cluster
configuration
''')

    log('Testing credentials...\n')
    with azure.get_token() as token:
        token  # Do nothing and keep pyflakes happy

    if 'username' in credentials:
        log('Testing whether the user credentials can expire...\n')
        password_policies = azure.graph('GET', '/me')[1]['passwordPolicies']
        if 'DisablePasswordExpiration' not in password_policies:
            raise Exception('The credentials might expire')

    log('Getting information about the environment...\n')
    for vmname in [conf['hostname'], conf['peername']]:
        log('Getting information about the VM %s...\n' % vmname)
        vm = azure.arm('GET', conf['baseId'] +
                       'microsoft.compute/virtualmachines/' + vmname)[1]
        if templateName != 'stack-ha':
            for interface_id in \
                    vm['properties']['networkProfile']['networkInterfaces']:
                if templateName == 'ha':
                    rid = interface_id['id']
                    interface_name = rid.split('/')[8]
                    if interface_name.find('eth0') != -1:
                        interfaces_test_rw(interface_id)
                else:
                    interfaces_test_rw(interface_id)

    if templateName not in ['ha', 'ha_terraform']:
        log('Testing authorization on routing tables...\n')
        for route_table in get_route_table_ids():
            test_rw(route_table)
        if templateName != 'stack-ha':
            log('Testing Azure load balancer...\n')
            test_load_balancer()

    if templateName != 'stack-ha':
        log('Testing cluster public IP address...\n')
        test_cluster_ip()

    log('Verifying Azure interface configuration...\n')
    for interface in cphaconf['ifs']:
        log('- Interface %s: local IP address = %s, peer IP address = %s\n' % (
            interface['name'], interface['ipaddr'],
            interface['other_member_if_ip']))

    log('\nAll tests were successful!\n')


def main():
    try:
        test()
    except Exception:
        log('Error:\n' + str(sys.exc_info()[1]) + '\n')
        sys.exit(1)


if __name__ == '__main__':
    main()
