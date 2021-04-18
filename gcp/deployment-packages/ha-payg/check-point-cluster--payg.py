# Copyright 2016 Check Point Software LTD.

import common
import copy
import default
import images
import password


MAX_ADDITIONAL_NICS = 6

GATEWAY = 'checkpoint-gateway'

PROJECT = 'checkpoint-public'
LICENSE = 'payg'
LICENCE_TYPE = 'cluster'

VERSIONS = {
    'R80.30': 'r8030-gw',
    'R80.40': 'r8040-gw',
    'R81': 'r81-gw'
}

TEMPLATE_NAME = 'cluster'
TEMPLATE_VERSION = '20210413'

CLUSTER_NET_FIELD = 'cluster-network'
MGMT_NET_FIELD = 'mgmt-network'
INTERNAL_NET_FIELD = 'internal-network{}'

MGMT_NIC = 1

startup_script = '''
#!/bin/bash

generatePassword="$(echo {generatePassword} | tr 'TF' 'tf')"
allowUploadDownload="{allowUploadDownload}"

echo "template_name: {templateName}" >> /etc/cloud-version
echo "template_version: {templateVersion}" >> /etc/cloud-version

function get_router() {{
    local interface="$1"
    local subnet_router_meta_path="computeMetadata/v1/instance/network-interfaces/$interface/gateway"
    local router="$(get-cloud-data.sh ${{subnet_router_meta_path}})"
    echo "${{router}}"
}}

function set_mgmt_if() {{
    mgmtNIC="{mgmtNIC}"
    local mgmt_int="eth0"
    if [ "X$mgmtNIC" == "XEphemeral Public IP (eth0)" ]; then
        mgmt_int="eth0"
    elif [ "X$mgmtNIC" == "XPrivate IP (eth1)" ]; then
        mgmt_int="eth1"
    fi
    local set_mgmt_if_out="$(clish -s -c "set management interface ${{mgmt_int}}")"
    echo "${{set_mgmt_if_out}}"
}}

function set_internal_static_routes() {{
    local private_cidrs='10.0.0.0/8 172.16.0.0/12 192.168.0.0/16'
    #Define interface for internal networks and configure
    local interface="$internalInterfaceNumber"
    local router=$(get_router $interface)
    clish -c 'lock database override'
    #Configure static routes destined to internal networks, defined in the RFC 1918, through the  internal interface
    for cidr in ${{private_cidrs}}; do
        echo "setting route to $cidr via gateway $router"
        echo "running  clish -c 'set static-route $cidr nexthop gateway address $router on' -s"
        clish -c "set static-route $cidr nexthop gateway address $router on" -s
    done
}}

function create_dynamic_objects() {{
    local is_managment="$1"
    local interfaces='eth0 eth1'
    for interface in ${{interfaces}}; do
        if ${{is_managment}}; then
            dynamic_objects -n "LocalGateway"
            dynamic_objects -n "LocalGatewayExternal"
            dynamic_objects -n "LocalGatewayInternal"
        else
            local addr="$(ip addr show dev $interface | awk "/inet/{{print \$2; exit}}" | cut -d / -f 1)"
            if [ "${{interface}}" == "eth0" ]; then
                dynamic_objects -n "LocalGateway" -r "$addr" "$addr" -a
                dynamic_objects -n "LocalGatewayExternal" -r "$addr" "$addr" -a
            else
                dynamic_objects -n "LocalGatewayInternal" -r "$addr" "$addr" -a
            fi
        fi
    done
}}


function post_status() {{
    local is_success="$1"
    local need_boot="$2"
    local status
    local value
    local instance_id

    if "{hasInternet}" ; then
        if "$is_success" ; then
            status="success"
            value="Success"
        else
            status="failure"
            value="Failure"
        fi
        instance_id="$(get-cloud-data.sh computeMetadata/v1/instance/id)"
        cat <<EOF >/etc/software-status
        $FWDIR/scripts/gcp.py POST "{config_url}/variables" \
            --body '{{
                "name": "{config_path}/variables/status/$status/$instance_id",
                "value": "$(echo $value | base64)"
            }}'
EOF
    fi

    create_dynamic_objects $installSecurityManagement

    if "$installSecurityGateway" ; then

        set_internal_static_routes
        set_mgmt_if

        ##########
        # DA Self update

        DAselfUpdateHappening=$(dbget installer:self_update_in_progress)
        if [ "X$DAselfUpdateHappening" == "X1" ]; then
            oldDApid=$(pidof DAService)
            countdown=121
            while [ $((--countdown)) -gt 0 ]
            do
                sleep 1
                DApid=$(pidof DAService)

                if [ "${{DApid:-$oldDApid}}" -ne "$oldDApid" ]; then
                    break
                fi
            done
            if [ $countdown -eq 0 ]; then
                dbset installer:self_update_in_progress
            fi
        fi

        ##########
    fi

    if "$need_boot" ; then
        if [ "{enableMonitoring}" = "True" ] ; then
            chkconfig --add gcp-statd
        fi
        shutdown -r now
    else
        service gcpd restart
        if [ "{enableMonitoring}" = "True" ] ; then
            chkconfig --add gcp-statd
            service gcp-statd start
        fi
    fi
}}
clish -c 'set user admin shell {shell}' -s

case "{installationType}" in
"Gateway only")
    installSecurityGateway=true
    gatewayClusterMember=false
    installSecurityManagement=false
    sicKey="{computed_sic_key}"
    internalInterfaceNumber=1
    ;;
"Management only")
    installSecurityGateway=false
    installSecurityManagement=true
    sicKey=notused
    ;;
"Manual Configuration")
    post_status true false
    exit 0
    ;;
"Gateway and Management (Standalone)")
    installSecurityGateway=true
    installSecurityManagement=true
    gatewayClusterMember=false
    sicKey=notused
    internalInterfaceNumber=1
    ;;
"Cluster")
    installSecurityGateway=true
    gatewayClusterMember=true
    installSecurityManagement=false
    sicKey="{sicKey}"
    internalInterfaceNumber=2
    ;;
"AutoScale")
    installSecurityGateway=true
    gatewayClusterMember=false
    installSecurityManagement=false
    sicKey="{computed_sic_key}"
    internalInterfaceNumber=1
    ;;
esac

conf="install_security_gw=$installSecurityGateway"
if ${{installSecurityGateway}} ; then
    conf="$conf&install_ppak=true"
    blink_conf="gateway_cluster_member=$gatewayClusterMember"
fi
conf="$conf&install_security_managment=$installSecurityManagement"
if ${{installSecurityManagement}} ; then
    if "$generatePassword" ; then
        managementAdminPassword="$(get-cloud-data.sh \
            computeMetadata/v1/instance/attributes/adminPasswordSourceMetadata)"
        conf="$conf&mgmt_admin_name=admin"
        conf="$conf&mgmt_admin_passwd=$managementAdminPassword"
    else
        conf="$conf&mgmt_admin_radio=gaia_admin"
    fi

    managementGUIClientNetwork="{managementGUIClientNetwork}"
    conf="$conf&install_mgmt_primary=true"

    if [ "0.0.0.0/0" = "$managementGUIClientNetwork" ]; then
        conf="$conf&mgmt_gui_clients_radio=any"
    else
        conf="$conf&mgmt_gui_clients_radio=network"
        ManagementGUIClientBase="$(echo ${{managementGUIClientNetwork}} | \
            cut -d / -f 1)"
        ManagementGUIClientMaskLength="$(echo ${{managementGUIClientNetwork}} | \
            cut -d / -f 2)"
        conf="$conf&mgmt_gui_clients_ip_field=$ManagementGUIClientBase"
        conf="$conf&mgmt_gui_clients_subnet_field=$ManagementGUIClientMaskLength"
    fi

fi

blink_conf="$blink_conf&ftw_sic_key=$sicKey"
blink_conf="$blink_conf&download_info=$allowUploadDownload"
blink_conf="$blink_conf&upload_info=$allowUploadDownload"

conf="$conf&$blink_conf"

if "$generatePassword" ; then
    blink_password="$(get-cloud-data.sh \
        computeMetadata/v1/instance/attributes/adminPasswordSourceMetadata)"
else
    blink_password="$(dd if=/dev/urandom count=1 \
        2>/dev/null | sha256sum | cut -c -28)"
fi
blink_conf="$blink_conf&admin_password_regular=$blink_password"

if [ "Gateway only" = "{installationType}" ] || [ "Cluster" = "{installationType}" ] || [ "AutoScale" = "{installationType}" ]; then
    config_cmd="blink_config -s $blink_conf"
else
    config_cmd="config_system -s $conf"
fi

if ${{config_cmd}} ; then
    if "$installSecurityManagement" ; then
        post_status true "$installSecurityGateway"
    elif [ "Cluster" = "{installationType}" ] ; then
        mgmt_subnet_gw="$(get-cloud-data.sh computeMetadata/v1/instance/network-interfaces/1/gateway)"
        sed -i 's/__CLUSTER_PUBLIC_IP_NAME__/'"{primary_cluster_address_name}"'/g' /etc/fw/conf/gcp-ha.json
        sed -i 's/__SECONDARY_PUBLIC_IP_NAME__/'"{secondary_cluster_address_name}"'/g' /etc/fw/conf/gcp-ha.json
        clish -c 'set static-route '"{managementNetwork}"' nexthop gateway address '"$mgmt_subnet_gw"' on' -s
        post_status true true
    else
        post_status true false
    fi
else
    post_status false false
fi

'''


def make_gw(context, name, zone, nics, passwd=None, depends_on=None):
    cg_version = context.properties['ha_version'].split(' ')[0]
    if 'gw' in VERSIONS[cg_version]:
        license_name = "{}-{}".format(LICENSE, LICENCE_TYPE)
    else:
        license_name = LICENSE
    family = '-'.join(['check-point', VERSIONS[cg_version], license_name])
    formatter = common.DefaultFormatter()

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


def create_external_addresses(prop, resources, member_a_nics, member_b_nics):
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
    fw_rule_name = '%s-%s-%s' % (deployment, net_prop_name, protocol)
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


@common.FormatErrorsDec
def generate_config(context):
    prop = context.properties

    validate_same_region(prop['zoneA'], prop['zoneB'])

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

    create_external_addresses(prop, resources, member_a_nics, member_b_nics)

    member_a_name = common.set_name_and_truncate(
        prop['deployment'], '-member-a')
    member_b_name = common.set_name_and_truncate(
        prop['deployment'], '-member-b')

    if prop['generatePassword']:
        passwd = password.GeneratePassword(12, False)
    else:
        passwd = ''

    member_a = make_gw(context, member_a_name, prop['zoneA'],
                       member_a_nics, passwd, gw_dependencies)
    member_b = make_gw(context, member_b_name, prop['zoneB'],
                       member_b_nics, passwd, gw_dependencies)

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
            'name': 'clusterIP',
            'value': '$(ref.{}.address)'.format(
                prop['primary_cluster_address_name'])
        },
        {
            'name': 'vmAName',
            'value': member_a_name,
        },
        {
            'name': 'vmAExternalIP',
            'value': '$(ref.{}.address)'.format(prop['member_a_address_name'])
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
            'name': 'vmBExternalIP',
            'value': '$(ref.{}.address)'.format(prop['member_b_address_name'])
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

    return common.MakeResource(resources, outputs)
