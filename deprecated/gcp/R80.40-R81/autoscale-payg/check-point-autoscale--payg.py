# Copyright 2016 Check Point Software LTD.

import common
import default
import images
import password

GATEWAY = 'checkpoint-gateway'
PROJECT = 'checkpoint-public'
LICENSE = 'payg'
LICENCE_TYPE = 'mig'

VERSIONS = {
    'R80.40-GW': 'r8040-gw',
    'R81-GW': 'r81-gw',
    'R81.10-GW': 'r8110-gw',
    'R81.20-GW': 'r8120-gw'
}

TEMPLATE_NAME = 'autoscale'
TEMPLATE_VERSION = '20231221'

startup_script = '''
#cloud-config
runcmd:
  - 'python3 /etc/cloud_config.py "generatePassword=\\"{generatePassword}\\"" "allowUploadDownload=\\"{allowUploadDownload}\\"" "templateName=\\"{templateName}\\"" "templateVersion=\\"{templateVersion}\\"" "mgmtNIC=\\"{mgmtNIC}\\"" "hasInternet=\\"{hasInternet}\\"" "config_url=\\"{config_url}\\"" "config_path=\\"{config_path}\\"" "installationType=\\"{installationType}\\"" "enableMonitoring=\\"{enableMonitoring}\\"" "shell=\\"{shell}\\"" "computed_sic_key=\\"{computed_sic_key}\\"" "sicKey=\\"{sicKey}\\"" "managementGUIClientNetwork=\\"{managementGUIClientNetwork}\\"" "primary_cluster_address_name=\\"{primary_cluster_address_name}\\"" "secondary_cluster_address_name=\\"{secondary_cluster_address_name}\\"" "managementNetwork=\\"{managementNetwork}\\"" "numAdditionalNICs=\\"{numAdditionalNICs}\\"" "smart1CloudToken=\\"{smart1CloudToken}\\"" "name=\\"{name}\\"" "zone=\\"{zoneConfig}\\"" "region=\\"{region}\\"" "osVersion=\\"{osVersion}\\"" "MaintenanceModePassword=\\"{maintenanceMode}\\""'
'''


def make_nic(context, net_name, subnet, external_ip=False):
    prop = context.properties
    network_interface = {
        'kind': 'compute#networkInterface',
        'network': common.GlobalNetworkLink(prop['project'], net_name)
    }
    if subnet:
        network_interface["subnetwork"] = common.MakeRegionalSubnetworkLink(
            prop['project'], prop['zone'], subnet)
    # add ephemeral public IP address
    if external_ip:
        network_interface["accessConfigs"] = \
            [make_access_config(name="external-nat")]
    return network_interface


def create_nics(context):
    prop = context.properties
    firewall_rules = create_firewall_rules(context)
    if firewall_rules:
        prop['resources'].extend(firewall_rules)
    networks = prop.setdefault('networks', ['default'])
    subnetworks = prop.get('subnetworks', [])
    nics = []
    for i in range(len(networks)):
        name = networks[i]
        subnet = ''
        external_ip = prop.get('gatewayExternalIP') and i == 0
        if subnetworks and i < len(subnetworks) and subnetworks[i]:
            subnet = subnetworks[i]
        network_interface = make_nic(context, name, subnet, external_ip)
        nics.append(network_interface)
    return nics


def create_firewall_rules(context):
    prop = context.properties
    deployment = prop['deployment']
    network = prop.setdefault('networks', ['default'])[0]
    firewall_rules = []
    protocols = ['Icmp', 'Udp', 'Tcp', 'Sctp', 'Esp']
    for protocol in protocols:
        proto = protocol.lower()
        source_ranges = prop.get(proto + 'SourceRanges', '')
        protocol_enabled = prop.get('enable' + protocol, '')
        if protocol_enabled and source_ranges:
            firewall_rules.append(make_firewall_rule(
                proto, source_ranges, deployment, network))
    return firewall_rules


def make_firewall_rule(protocol, source_ranges, deployment, net_name):
    fw_rule_name = '%s-%s-%s' % (deployment[:34], net_name[:22], protocol)
    ranges = []
    ranges_list = source_ranges.split(',')
    for source_range in ranges_list:
        ranges.append(source_range.replace(" ", ""))
    firewall_rule = {
        'type': default.FIREWALL,
        'name': fw_rule_name,
        'properties': {
            'network': 'global/networks/' + net_name,
            'sourceRanges': ranges,
            'targetTags': [GATEWAY],
            'allowed': [{'IPProtocol': protocol}]
        }
    }
    return firewall_rule


def create_instance_template(context,
                             name,
                             nics,
                             depends_on=None,
                             gw_version=VERSIONS['R81.20-GW']):
    if 'gw' in gw_version:
        license_name = "{}-{}".format(LICENSE, LICENCE_TYPE)
    else:
        license_name = LICENSE
    family = '-'.join(['check-point', gw_version, license_name])
    formatter = common.DefaultFormatter()
    instance_template_name = common.AutoName(name, default.TEMPLATE)
    instance_template = {
        "type": default.TEMPLATE,
        "name": instance_template_name,
        'metadata': {
            'dependsOn': depends_on
        },
        "properties": {
            "project": context.properties['project'],
            "properties": {
                "canIpForward": True,
                "disks": [{"autoDelete": True,
                           "boot": True,
                           "deviceName": common.set_name_and_truncate(
                               context.properties['deployment'],
                               '-{}-boot'.format(name)),
                           "index": 0,
                           "initializeParams": {
                               "diskType":
                                   context.properties['diskType'],
                               "diskSizeGb":
                                   context.properties['bootDiskSizeGb'],
                               "sourceImage":
                                   'projects/%s/global/images/%s' % (
                                       PROJECT, images.IMAGES[family])
                           },
                           "kind": 'compute#attachedDisk',
                           "mode": "READ_WRITE",
                           "type": "PERSISTENT"}],
                "machineType": context.properties['machineType'],
                "networkInterfaces": nics,
                'metadata': {
                    "kind": 'compute#metadata',
                    'items': [
                        {
                            'key': 'startup-script',
                            'value': formatter.format(
                                startup_script, **context.properties)
                        },
                        {
                            'key': 'serial-port-enable',
                            'value': 'true'
                        }
                    ]},
                "scheduling": {
                    "automaticRestart": True,
                    "onHostMaintenance": "MIGRATE",
                    "preemptible": False
                },
                "serviceAccounts": [
                    {
                        "email": "default",
                        "scopes": [
                            "https://www.googleapis.com/" +
                            "auth/devstorage.read_only",
                            "https://www.googleapis.com/auth/logging.write",
                            "https://www.googleapis.com/auth/monitoring.write",
                            "https://www.googleapis.com/auth/pubsub",
                            "https://www.googleapis.com/" +
                            "auth/service.management.readonly",
                            "https://www.googleapis.com/auth/servicecontrol",
                            "https://www.googleapis.com/auth/trace.append"
                        ]
                    }],
                "tags": {
                    "items": [
                        'x-chkp-management--{}'.
                        format(context.properties['managementName']),
                        'x-chkp-template--{}'.
                        format(context.properties['AutoProvTemplate']),
                        'checkpoint-gateway'
                    ]
                }
            }
        }
    }
    tagItems = instance_template['properties']['properties']['tags']['items']
    if context.properties['mgmtNIC'] == 'Ephemeral Public IP (eth0)':
        tagItems.append("x-chkp-ip-address--public")
        tagItems.append("x-chkp-management-interface--eth0")
    elif context.properties['mgmtNIC'] == 'Private IP (eth1)':
        tagItems.append("x-chkp-ip-address--private")
        tagItems.append("x-chkp-management-interface--eth1")
    if context.properties['networkDefinedByRoutes']:
        tagItems.append("x-chkp-topology-eth1--internal")
        tagItems.append("x-chkp-topology-settings-eth1"
                        "--network-defined-by-routes")
    metadata = instance_template['properties']['properties']['metadata']
    if 'instanceSSHKey' in context.properties:
        metadata['items'].append(
            {
                'key': 'instanceSSHKey',
                'value': context.properties['instanceSSHKey']
            }
        )
    passwd = ''
    if context.properties['generatePassword']:
        passwd = password.GeneratePassword(12, False)
        metadata['items'].append(
            {
                'key': 'adminPasswordSourceMetadata',
                'value': passwd
            }
        )
    return instance_template, passwd


def GenerateAutscaledGroup(context, name,
                           instance_template, depends_on=None):
    prop = context.properties
    igm_name = common.AutoName(name, default.IGM)
    depends_on = depends_on
    resource = {
        'name': igm_name,
        'metadata': {
            'dependsOn': depends_on
        },
        'type': default.REGION_IGM,
        'properties': {
            'region': common.ZoneToRegion(prop.get("zone")),
            'baseInstanceName': name,
            'instanceTemplate': '$(ref.' + instance_template + '.selfLink)',
            'targetSize': prop.get("minInstances"),
            # 'autoHealingPolicies': [{
            #                    'initialDelaySec': 60
            #    }]
        }
    }
    return resource


def CreateAutscaler(context, name,
                    igm, cpu_usage, depends_on=None):
    prop = context.properties
    autoscaler_name = common.AutoName(name, default.AUTOSCALER)
    depends_on = depends_on
    cpu_usage = float(cpu_usage) / 100
    resource = {
        'name': autoscaler_name,
        'metadata': {
            'dependsOn': depends_on
        },
        'type': default.REGION_AUTOSCALER,
        'properties': {
            'target': '$(ref.' + igm + '.selfLink)',
            'region': common.ZoneToRegion(prop.get("zone")),
            'autoscalingPolicy': {
                'minNumReplicas': int(prop.get("minInstances")),
                'maxNumReplicas': int(prop.get("maxInstances")),
                'cpuUtilization': {
                    'utilizationTarget': cpu_usage
                },
                'coolDownPeriodSec': 90
            }
        }
    }
    return resource


def make_access_config(name=None):
    access_config = {
        'type': default.ONE_NAT,
        "kind": 'compute#accessConfig'
    }
    if name:
        access_config['name'] = name
    return access_config


def validate_region(test_zone, valid_region):
    test_region = common.ZoneToRegion(test_zone)
    if test_region != valid_region:
        err_msg = '{} is in region {}. All subnets must be ' + \
                  'in the same region ({})'
        raise common.Error(
            err_msg.format(test_zone, test_region, valid_region)
        )


@common.FormatErrorsDec
def generate_config(context):
    # This method will:
    # 1. Create a instance template for a security GW
    # (with a tag for the managing security server)
    # 2. Create a managed instance group
    # (based on the instance template and zones list provided by the user)
    # 3. Configure autoscaling
    # (based on min, max & policy settings provided by the user)
    prop = context.properties
    prop['deployment'] = context.env['deployment']
    prop['project'] = context.env['project']
    prop['templateName'] = TEMPLATE_NAME
    prop['templateVersion'] = TEMPLATE_VERSION
    prop['allowUploadDownload'] = str(prop['allowUploadDownload']).lower()
    prop['hasInternet'] = 'true'  # via Google Private Access
    prop['installationType'] = 'AutoScale'
    prop['resources'] = []
    prop['outputs'] = []
    prop['gw_dependencies'] = []
    prop['computed_sic_key'] = password.GeneratePassword(12, False)
    prop['gatewayExternalIP'] = (prop['mgmtNIC'] ==
                                 'Ephemeral Public IP (eth0)')
    version_chosen = prop['autoscalingVersion'].split(' ')[0] + "-GW"
    prop['osVersion'] = prop['autoscalingVersion'].split(' ')[0].replace(
        ".", "")
    nics = create_nics(context)
    gw_template, passwd = create_instance_template(context,
                                                   prop['deployment'],
                                                   nics,
                                                   depends_on=prop[
                                                       'gw_dependencies'],
                                                   gw_version=VERSIONS[
                                                       version_chosen])
    prop['resources'] += [gw_template]
    prop['igm_dependencies'] = [gw_template['name']]
    igm = GenerateAutscaledGroup(context,
                                 prop['deployment'],
                                 gw_template['name'],
                                 prop['igm_dependencies'])
    prop['resources'] += [igm]
    prop['autoscaler_dependencies'] = [igm['name']]
    cpu_usage = prop.get("cpuUsage")
    autoscaler = CreateAutscaler(context,
                                 prop['deployment'],
                                 igm['name'],
                                 cpu_usage,
                                 prop['autoscaler_dependencies'])
    prop['resources'] += [autoscaler]
    prop['outputs'] += [
        {
            'name': 'deployment',
            'value': prop['deployment']
        },
        {
            'name': 'project',
            'value': prop['project']
        },
        {
            'name': 'instanceTemplateName',
            'value': gw_template['name']
        },
        {
            'name': 'InstanceTemplateLink',
            'value': common.Ref(gw_template['name'])
        },
        {
            'name': 'IGMname',
            'value': igm['name']
        },
        {
            'name': 'IGMLink',
            'value': common.RefGroup(igm['name'])
        },
        {
            'name': 'cpuUsagePercentage',
            'value': str(int(prop['cpuUsage'])) + '%'
        },
        {
            'name': 'minInstancesInt',
            'value': str(int(prop['minInstances']))
        },
        {
            'name': 'maxInstancesInt',
            'value': str(int(prop['maxInstances']))
        },
        {
            'name': 'password',
            'value': passwd
        }
    ]
    return common.MakeResource(prop['resources'], prop['outputs'])
