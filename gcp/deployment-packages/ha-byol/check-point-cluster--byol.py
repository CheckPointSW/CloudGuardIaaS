# Copyright 2016 Check Point Software LTD.

import common
import copy
import default
import images
import password


MAX_ADDITIONAL_NICS = 6

GATEWAY = 'checkpoint-gateway'

PROJECT = 'checkpoint-public'
LICENSE = 'byol'
LICENCE_TYPE = 'cluster'

VERSIONS = {
    'R81.10': 'r8110-gw',
    'R81.20': 'r8120-gw',
    'R82': 'r82-gw'
}

TEMPLATE_NAME = 'cluster'
TEMPLATE_VERSION = '20240714'

CLUSTER_NET_FIELD = 'cluster-network'
MGMT_NET_FIELD = 'mgmt-network'
INTERNAL_NET_FIELD = 'internal-network{}'

MGMT_NIC = 1

NO_PUBLIC_IP = 'no-public-ip'

startup_script = '''
#cloud-config
runcmd:
  - 'python3 /etc/cloud_config.py "generatePassword=\\"{generatePassword}\\"" "allowUploadDownload=\\"{allowUploadDownload}\\"" "templateName=\\"{templateName}\\"" "templateVersion=\\"{templateVersion}\\"" "mgmtNIC=\\"{mgmtNIC}\\"" "hasInternet=\\"{hasInternet}\\"" "config_url=\\"{config_url}\\"" "config_path=\\"{config_path}\\"" "installationType=\\"{installationType}\\"" "enableMonitoring=\\"{enableMonitoring}\\"" "shell=\\"{shell}\\"" "computed_sic_key=\\"{computed_sic_key}\\"" "sicKey=\\"{sicKey}\\"" "managementGUIClientNetwork=\\"{managementGUIClientNetwork}\\"" "primary_cluster_address_name=\\"{primary_cluster_address_name}\\"" "secondary_cluster_address_name=\\"{secondary_cluster_address_name}\\"" "managementNetwork=\\"{managementNetwork}\\"" "numAdditionalNICs=\\"{numAdditionalNICs}\\"" "smart1CloudToken=\\"{smart1CloudToken}\\"" "name=\\"{name}\\"" "zone=\\"{zoneConfig}\\"" "region=\\"{region}\\"" "osVersion=\\"{osVersion}\\"" "MaintenanceModePassword=\\"{maintenanceMode}\\""'
'''


def make_gw(context, name, zone, nics, passwd=None, depends_on=None,
            smart1cloudToken=None):
    cg_version = context.properties['ha_version'].split(' ')[0]
    if 'gw' in VERSIONS[cg_version]:
        license_name = "{}-{}".format(LICENSE, LICENCE_TYPE)
    else:
        license_name = LICENSE
    family = '-'.join(['check-point', VERSIONS[cg_version], license_name])
    formatter = common.DefaultFormatter()

    context.properties['smart1CloudToken'] = smart1cloudToken
    context.properties['name'] = name
    context.properties['zoneConfig'] = zone
    context.properties['osVersion'] = cg_version.replace(".", "")

    gw = {
        'type': default.INSTANCE,
        'name': name,
        'metadata': {
            'dependsOn': depends_on
        },
        'properties': {
            'description': 'CloudGuard Highly Available Security Cluster',
            'zone': zone,
            'tags': {
                'items': [GATEWAY],
            },
            'machineType': common.MakeLocalComputeLink(
                context, default.MACHINETYPE, zone),
            'canIpForward': True,
            'networkInterfaces': nics,
            'disks': [{
                'autoDelete': True,
                'boot': True,
                'deviceName': common.set_name_and_truncate(
                    context.properties['deployment'],
                    '-{}-boot'.format(name)),
                'initializeParams': {
                    'diskType': common.MakeLocalComputeLink(
                        context, default.DISKTYPE, zone),
                    'diskSizeGb': context.properties['bootDiskSizeGb'],
                    'sourceImage':
                        'projects/%s/global/images/%s' % (
                            PROJECT, images.IMAGES[family]),
                },
                'type': 'PERSISTENT',
            }],
            'metadata': {
                'items': [
                    {
                        'key': 'startup-script',
                        'value': formatter.format(
                            startup_script, **context.properties)
                    }
                ]
            },
            'serviceAccounts': [{
                'email': 'default',
                'scopes': [
                    'https://www.googleapis.com/auth/monitoring.write',
                    'https://www.googleapis.com/auth/compute',
                    'https://www.googleapis.com/auth/cloudruntimeconfig'
                ],
            }]
        }
    }

    if 'instanceSSHKey' in context.properties:
        gw['properties']['metadata']['items'].append(
            {
                'key': 'instanceSSHKey',
                'value': context.properties['instanceSSHKey']
            }
        )

    if passwd:
        gw['properties']['metadata']['items'].append(
            {
                'key': 'adminPasswordSourceMetadata',
                'value': passwd
            }
        )

    return gw


def make_access_config(ip, name=None):
    access_config = {
        'type': default.ONE_NAT,
        'natIP': ip
    }

    if name:
        access_config['name'] = name

    return access_config


def make_static_address(prop, name):
    address = {
        'name': name,
        'type': default.ADDRESS,
        'properties': {
            'name': name,
            'region': prop['region']
        }
    }

    return address


def create_external_addresses_if_needed(
        prop, resources, member_a_nics, member_b_nics):
    if not prop['deployWithPublicIPs']:
        prop['primary_cluster_address_name'] = NO_PUBLIC_IP
        prop['secondary_cluster_address_name'] = NO_PUBLIC_IP
    else:
        member_a_address_name = common.set_name_and_truncate(
            prop['deployment'], '-member-a-address')
        member_b_address_name = common.set_name_and_truncate(
            prop['deployment'], '-member-b-address')

        prop['member_a_address_name'] = member_a_address_name
        prop['member_b_address_name'] = member_b_address_name

        member_a_address = make_static_address(prop, member_a_address_name)
        member_b_address = make_static_address(prop, member_b_address_name)

        resources += [member_a_address, member_b_address]

        member_a_nics[MGMT_NIC]['accessConfigs'] = [make_access_config(
            '$(ref.{}.address)'.format(member_a_address_name))]
        member_b_nics[MGMT_NIC]['accessConfigs'] = [make_access_config(
            '$(ref.{}.address)'.format(member_b_address_name))]

        primary_cluster_address_name = common.set_name_and_truncate(
            prop['deployment'], '-primary-cluster-address')
        secondary_cluster_address_name = common.set_name_and_truncate(
            prop['deployment'], '-secondary-cluster-address')

        primary_cluster_address = make_static_address(
            prop, primary_cluster_address_name)
        secondary_cluster_address = make_static_address(
            prop, secondary_cluster_address_name)

        resources += [primary_cluster_address, secondary_cluster_address]

        prop['primary_cluster_address_name'] = primary_cluster_address_name
        prop['secondary_cluster_address_name'] = secondary_cluster_address_name


def make_nic(prop, net_name, subnet_name):
    network_interface = {
        'network': ''.join([default.COMPUTE_URL_BASE, 'projects/',
                            prop['project'], '/global/networks/',
                            net_name]),
        'subnetwork': ''.join([default.COMPUTE_URL_BASE, 'projects/',
                               prop['project'], '/regions/', prop['region'],
                               '/subnetworks/', subnet_name])
    }

    return network_interface


def make_subnet(prop, name, net_name, cidr, private_google_access=False):
    subnet = {
        'type': default.VPC_SUBNET,
        'name': name,
        'metadata': {
            'dependsOn': [net_name]
        },
        'properties': {
            'network': 'projects/{}/global'
                       '/networks/{}'.format(prop['project'], net_name),
            'region': prop['region'],
            'ipCidrRange': cidr,
            'privateIpGoogleAccess': private_google_access,
            'enableFlowLogs': False
        }
    }

    return subnet


def make_net(name):
    net = {
        'type': default.VPC,
        'name': name,
        'properties': {
            'autoCreateSubnetworks': False
        }
    }

    return net


def get_or_create_net(prop, name, resources, gw_dependencies,
                      private_google_access=False, create_firewall=False):
    net_cidr = prop.get(name + '-cidr')

    if net_cidr:
        net_name = '{}-{}'.format(prop['deployment'][:20], name)
        subnet_name = '{}-subnet'.format(net_name)
        net = make_net(net_name)
        subnet = make_subnet(
            prop, subnet_name, net_name, net_cidr, private_google_access)

        resources += [net, subnet]
        gw_dependencies.append(subnet_name)
    else:
        net_name = prop.get(name + '-name')
        subnet_name = prop.get(name + '-subnetwork-name')
        if not subnet_name:
            raise common.Error(
                'Network {} is missing.'.format(net_name.split('-')))

    if create_firewall:
        firewall_rules = create_firewall_rules(prop, name, net_name, net_cidr)
        if firewall_rules:
            resources.extend(firewall_rules)

    return net_name, subnet_name


def create_firewall_rules(prop, net_prop_name, net_name, net_cidr):
    deployment = prop['deployment']
    firewall_rules = []
    protocols = ['Icmp', 'Udp', 'Tcp', 'Sctp', 'Esp']
    for protocol in protocols:
        proto = protocol.lower()
        source_ranges = prop.get(net_prop_name + '_' + proto +
                                 'SourceRanges', '')
        protocol_enabled = prop.get(net_prop_name + '_enable' + protocol, '')
        if protocol_enabled and source_ranges:
            firewall_rules.append(
                make_firewall_rule(proto, source_ranges, deployment,
                                   net_prop_name, net_name, net_cidr))

    return firewall_rules


def make_firewall_rule(protocol, source_ranges, deployment, net_prop_name,
                       net_name, net_cidr):
    fw_rule_name = '%s-%s-%s' % (deployment[:40], net_prop_name, protocol)
    ranges_list = source_ranges.split(',')
    ranges = []
    for source_range in ranges_list:
        ranges.append(source_range.replace(" ", ""))
    firewall_rule = {
        'type': default.FIREWALL,
        'name': fw_rule_name,
        'properties': {
            'network': 'global/networks/' + net_name,
            'sourceRanges': ranges,
            'targetTags': [GATEWAY],
            'allowed': [{'IPProtocol': protocol}],
        }
    }

    if net_cidr:
        firewall_rule['metadata'] = {
            'dependsOn': [net_name]
        }

    return firewall_rule


def add_readiness_waiter(prop, resources):
    deployment_config = common.set_name_and_truncate(
        prop['deployment'], '-config')

    prop['config_path'] = 'projects/{}/configs/{}'.format(
        prop['project'], deployment_config)
    prop['config_url'] = (
        'https://runtimeconfig.googleapis.com/v1beta1/{}'.format(
            prop['config_path']))

    resources.append(
        {
            'name': deployment_config,
            'type': 'runtimeconfig.v1beta1.config',
            'properties': {
                'config': deployment_config,
                'description': (
                    'Holds software readiness status '
                    'for deployment {}').format(prop['deployment'])
            }
        }
    )

    resources.append(
        {
            'name': common.set_name_and_truncate(
                prop['deployment'], '-software'),
            'type': 'runtimeconfig.v1beta1.waiter',
            'metadata': {
                'dependsOn': [],
            },
            'properties': {
                'parent': '$(ref.{}.name)'.format(deployment_config),
                'waiter': 'software',
                'timeout': '1800s',
                'success': {
                    'cardinality': {
                        'number': 2,
                        'path': 'status/success',
                    },
                },
                'failure': {
                    'cardinality': {
                        'number': 1,
                        'path': 'status/failure',
                    },
                },
            },
        }
    )


def validate_same_region(zone_a, zone_b):
    if not common.ZoneToRegion(zone_a) == common.ZoneToRegion(zone_b):
        raise common.Error('Member A Zone ({}) and Member B Zone ({}) '
                           'are not in the same region'.format(zone_a, zone_b))


def validate_both_tokens(token_a, token_b):
    if (not token_a and token_b) or (not token_b and token_a) or \
            (token_a and token_a == token_b):
        raise common.Error('To connect to Smart-1 Cloud, \
         you must provide two tokens (one per member)')


def validate_mgmt_network_if_required(token_a, mgmt_network):
    if not token_a and mgmt_network == "S1C":
        raise common.Error(
            'Public address of the Security Management Server is required')


@common.FormatErrorsDec
def generate_config(context):
    prop = context.properties

    validate_same_region(prop['zoneA'], prop['zoneB'])
    validate_both_tokens(prop['smart1CloudTokenA'], prop['smart1CloudTokenB'])
    validate_mgmt_network_if_required(
        prop['smart1CloudTokenA'], prop['managementNetwork'])

    prop['deployment'] = context.env['deployment']
    prop['project'] = context.env['project']
    prop['region'] = common.ZoneToRegion(prop['zoneA'])
    prop['templateName'] = TEMPLATE_NAME
    prop['templateVersion'] = TEMPLATE_VERSION
    prop['allowUploadDownload'] = str(prop['allowUploadDownload']).lower()
    prop['hasInternet'] = 'true'  # via Google Private Access
    prop['installationType'] = 'Cluster'

    resources = []
    outputs = []
    gw_dependencies = []
    member_a_nics = []

    add_readiness_waiter(prop, resources)

    cluster_net_name, cluster_subnet_name = get_or_create_net(
        prop, CLUSTER_NET_FIELD, resources, gw_dependencies, True, True)
    member_a_nics.append(make_nic(prop, cluster_net_name, cluster_subnet_name))

    mgmt_net_name, mgmt_subnet_name = get_or_create_net(
        prop, MGMT_NET_FIELD, resources, gw_dependencies, False, True)
    member_a_nics.append(make_nic(prop, mgmt_net_name, mgmt_subnet_name))

    for ifnum in range(1, prop['numInternalNetworks'] + 1):
        int_net_name, int_subnet_name = get_or_create_net(
            prop, INTERNAL_NET_FIELD.format(ifnum), resources,
            gw_dependencies)
        member_a_nics.append(make_nic(prop, int_net_name, int_subnet_name))

    member_b_nics = copy.deepcopy(member_a_nics)

    create_external_addresses_if_needed(
        prop, resources, member_a_nics, member_b_nics)

    member_a_name = common.set_name_and_truncate(
        prop['deployment'], '-member-a')
    member_b_name = common.set_name_and_truncate(
        prop['deployment'], '-member-b')

    if prop['generatePassword']:
        passwd = password.GeneratePassword(12, False)
    else:
        passwd = ''

    member_a = make_gw(context, member_a_name, prop['zoneA'],
                       member_a_nics, passwd, gw_dependencies,
                       prop['smart1CloudTokenA'])
    member_b = make_gw(context, member_b_name, prop['zoneB'],
                       member_b_nics, passwd, gw_dependencies,
                       prop['smart1CloudTokenB'])

    resources += [member_a, member_b]

    outputs += [
        {
            'name': 'deployment',
            'value': prop['deployment']
        },
        {
            'name': 'project',
            'value': prop['project']
        },
        {
            'name': 'vmAName',
            'value': member_a_name,
        },
        {
            'name': 'vmASelfLink',
            'value': '$(ref.{}.selfLink)'.format(member_a_name),
        },
        {
            'name': 'vmBName',
            'value': member_b_name,
        },
        {
            'name': 'vmBSelfLink',
            'value': '$(ref.{}.selfLink)'.format(member_b_name),
        },
        {
            'name': 'password',
            'value': passwd
        }
    ]

    if prop['deployWithPublicIPs']:
        outputs += [
            {
                'name': 'clusterIP',
                'value': '$(ref.{}.address)'.format(
                    prop['primary_cluster_address_name'])
            },
            {
                'name': 'vmAExternalIP',
                'value': '$(ref.{}.address)'.format(
                    prop['member_a_address_name'])
            },
            {
                'name': 'vmBExternalIP',
                'value': '$(ref.{}.address)'.format(
                    prop['member_b_address_name'])
            }
        ]

    return common.MakeResource(resources, outputs)
