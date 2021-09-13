# Copyright 2016 Check Point Software LTD.
import common
import default
import images
import password

GATEWAY = 'checkpoint-gateway'
MANAGEMENT = 'checkpoint-management'

PROJECT = 'checkpoint-public'
LICENSE = 'payg'
LICENCE_TYPE = 'single'

VERSIONS = {
    'R80.30': 'r8030',
    'R80.30-GW': 'r8030-gw',
    'R80.40': 'r8040',
    'R80.40-GW': 'r8040-gw',
    'R81': 'r81',
    'R81-GW': 'r81-gw',
    'R81.10': 'r8110',
    'R81.10-GW': 'r8110-gw'
}

ADDITIONAL_NETWORK = 'additionalNetwork{}'
ADDITIONAL_SUBNET = 'additionalSubnetwork{}'
ADDITIONAL_EXTERNAL_IP = 'externalIP{}'
MAX_NICS = 8

TEMPLATE_NAME = 'single'
TEMPLATE_VERSION = '20210912'

ATTRIBUTES = {
    'Gateway and Management (Standalone)': {
        'tags': [GATEWAY, MANAGEMENT],
        'description': 'Check Point Security Gateway and Management',
        'canIpForward': True,
    },
    'Management only': {
        'tags': [MANAGEMENT],
        'description': 'Check Point Security Management',
        'canIpForward': False,
    },
    'Gateway only': {
        'tags': [GATEWAY],
        'description': 'Check Point Security Gateway',
        'canIpForward': True,
    },
    'Manual Configuration': {
        'tags': [],
        'description': 'Check Point',
        'canIpForward': True,
    }
}

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

    if [ "$installSecurityManagement" -a "Management only" = "{installationType}" ] ; then
        public_ip="$(get-cloud-data.sh computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)"
        declare -i attempts=0
        declare -i max_attempts=80
        mgmt_cli -r true discard
        result=$?
        while [ $result -ne 0 ] && [ $attempts -lt $max_attempts ]
        do
            attempts=$attempts+1
            sleep 30
            mgmt_cli -r true discard
            result=$?
        done
        generic_objects="$(mgmt_cli -r true show-generic-objects class-name com.checkpoint.objects.classes.dummy.CpmiHostCkp details-level full -f json)"
        uid="$(echo $generic_objects | jq .objects | jq .[0] | jq .uid)"
        if [ ! -z "$public_ip" ] && [ ! -z "${{uid:1:-1}}" ] ; then
            mgmt_cli -r true set-generic-object uid $uid ipaddr $public_ip
        fi
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


def set_name_and_truncate(primary, secondary, maxlength=62):
    return '%s%s' % (primary[:maxlength - len(secondary)], secondary)


def MakeStaticAddress(vm_name, zone, ifnum=None):
    """Creates a static IP address resource; returns it and the natIP."""
    if ifnum:
        address_name = set_name_and_truncate(vm_name,
                                             '-address-{}'.format(ifnum))
    else:
        address_name = set_name_and_truncate(vm_name, '-address')
    address_resource = {
        'name': address_name,
        'type': default.ADDRESS,
        'properties': {
            'name': address_name,
            'region': common.ZoneToRegion(zone),
        },
    }
    return address_resource, '$(ref.%s.address)' % address_name


def make_access_config(resources, vm_name, zone, static, index=None):
    name = 'external-address'
    if index:
        name += '-{}'.format(index)
    access_config = {
        'name': name,
        'type': default.ONE_NAT
    }
    if static:
        address_resource, nat_ip = MakeStaticAddress(vm_name, zone, index)
        resources.append(address_resource)
        access_config['natIP'] = nat_ip
    return access_config


def create_firewall_rules(prop, net_name, fw_rule_name_prefix, mgmt=False,
                          uid=''):
    firewall_rules = []
    protocols = ['Icmp', 'Udp', 'Tcp', 'Sctp', 'Esp']
    if mgmt:
        protocols.remove('Tcp')
    for protocol in protocols:
        proto = protocol.lower()
        source_ranges = prop.get('network' + '_' + proto + 'SourceRanges', '')
        protocol_enabled = prop.get('network' + '_enable' + protocol, '')
        if protocol_enabled and source_ranges:
            firewall_rules.append(make_firewall_rule(
                proto, source_ranges, net_name, fw_rule_name_prefix, mgmt,
                uid))
    return firewall_rules


def make_firewall_rule(protocol, source_ranges,
                       net_name, fw_rule_name_prefix, mgmt=False, uid=''):
    ranges = []
    ranges_list = source_ranges.split(',')
    for source_range in ranges_list:
        ranges.append(source_range.replace(" ", ""))
    fw_rule_name = fw_rule_name_prefix + '-' + protocol
    if mgmt:
        targetTags = [uid]
    else:
        targetTags = [GATEWAY]
    firewall_rule = {
        'type': default.FIREWALL,
        'name': fw_rule_name,
        'properties': {
            'network': 'global/networks/' + net_name,
            'sourceRanges': ranges,
            'targetTags': targetTags,
            'allowed': [{'IPProtocol': protocol}],
        }
    }
    return firewall_rule


def generate_config(context):
    """Creates the gateway."""
    prop = context.properties
    prop['cloudguardVersion'], _, prop['installationType'] = prop[
        'installationType'].partition(' ')
    prop['templateName'] = TEMPLATE_NAME
    prop['templateVersion'] = TEMPLATE_VERSION
    prop['allowUploadDownload'] = str(prop['allowUploadDownload']).lower()
    if not prop['managementGUIClientNetwork'] and prop['installationType'] in {
            'Gateway and Management (Standalone)', 'Management only'}:
        raise Exception('Allowed GUI clients are required when installing '
                        'a management server')
    for k in ['managementGUIClientNetwork']:
        prop.setdefault(k, '')
    resources = []
    outputs = []
    network_interfaces = []
    external_ifs = []
    zone = prop['zone']
    deployment = context.env['deployment']
    vm_name = set_name_and_truncate(deployment, '-vm')
    access_configs = []
    if prop['externalIP'] != 'None':
        access_config = make_access_config(resources, vm_name, zone,
                                           'Static' == prop['externalIP'])
        access_configs.append(access_config)
        external_ifs.append(0)
        prop['hasInternet'] = 'true'
    else:
        prop['hasInternet'] = 'false'
    network = common.MakeGlobalComputeLink(context, default.NETWORK)
    networks = {prop['network']}
    network_interface = {
        'network': network,
        'accessConfigs': access_configs,
    }
    if default.SUBNETWORK in prop:
        network_interface['subnetwork'] = common.MakeSubnetworkComputeLink(
            context, default.SUBNETWORK)
    network_interfaces.append(network_interface)
    for ifnum in range(1, prop['numAdditionalNICs'] + 1):
        net = prop.get(ADDITIONAL_NETWORK.format(ifnum))
        subnet = prop.get(ADDITIONAL_SUBNET.format(ifnum))
        ext_ip = prop.get(ADDITIONAL_EXTERNAL_IP.format(ifnum))
        if not net or not subnet:
            raise Exception(
                'Missing network parameters for interface {}'.format(ifnum))
        if net in networks:
            raise Exception('Cannot use network "' + net + '" more than once')
        networks.add(net)
        net = ''.join([
            default.COMPUTE_URL_BASE,
            'projects/', context.env['project'], '/global/networks/', net])
        subnet = ''.join([
            default.COMPUTE_URL_BASE,
            'projects/', context.env['project'],
            '/regions/', common.ZoneToRegion(zone), '/subnetworks/', subnet])
        network_interface = {
            'network': net,
            'subnetwork': subnet,
        }
        if 'None' != ext_ip:
            external_ifs.append(ifnum)
            access_config = make_access_config(
                resources, vm_name, zone, 'Static' == ext_ip, ifnum + 1)
            access_configs = [access_config]
            network_interface['accessConfigs'] = access_configs
            if not prop.get('hasInternet') or 'false' == prop['hasInternet']:
                prop['hasInternet'] = 'true'
        network_interfaces.append(network_interface)
    for ifnum in range(prop['numAdditionalNICs'] + 1, MAX_NICS):
        prop.pop(ADDITIONAL_NETWORK.format(ifnum), None)
        prop.pop(ADDITIONAL_SUBNET.format(ifnum), None)
        prop.pop(ADDITIONAL_EXTERNAL_IP.format(ifnum), None)
    deployment_config = set_name_and_truncate(deployment, '-config')
    prop['config_url'] = ('https://runtimeconfig.googleapis.com/v1beta1/' +
                          'projects/' + context.env[
                              'project'] + '/configs/' + deployment_config)
    prop['config_path'] = '/'.join(prop['config_url'].split('/')[-4:])
    prop['deployment_config'] = deployment_config
    tags = ATTRIBUTES[prop['installationType']]['tags']
    uid = set_name_and_truncate(vm_name, '-' + password.GeneratePassword(
        8, False).lower())
    if prop['installationType'] == 'Gateway only':
        prop['cloudguardVersion'] += '-GW'
        if not prop.get('sicKey'):
            prop['computed_sic_key'] = password.GeneratePassword(12, False)
        else:
            prop['computed_sic_key'] = prop['sicKey']
    else:
        prop['computed_sic_key'] = 'N/A'
    outputs.append({
        'name': 'sicKey',
        'value': prop['computed_sic_key'],
    }, )
    if 'gw' in VERSIONS[prop['cloudguardVersion']]:
        license_name = "{}-{}".format(LICENSE, LICENCE_TYPE)
    else:
        license_name = LICENSE
    family = '-'.join(['check-point', VERSIONS[prop['cloudguardVersion']],
                       license_name])
    formatter = common.DefaultFormatter()
    gw = {
        'type': default.INSTANCE,
        'name': vm_name,
        'properties': {
            'description': ATTRIBUTES[prop['installationType']]['description'],
            'zone': zone,
            'tags': {
                'items': tags + [uid],
            },
            'machineType': common.MakeLocalComputeLink(
                context, default.MACHINETYPE),
            'canIpForward': ATTRIBUTES[
                prop['installationType']]['canIpForward'],
            'networkInterfaces': network_interfaces,
            'disks': [{
                'autoDelete': True,
                'boot': True,
                'deviceName': common.AutoName(
                    context.env['name'], default.DISK, 'boot'),
                'initializeParams': {
                    'diskType': common.MakeLocalComputeLink(
                        context, default.DISKTYPE),
                    'diskSizeGb': prop['bootDiskSizeGb'],
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
                        'value': formatter.format(startup_script, **prop)
                    },
                ]
            },
            'serviceAccounts': [{
                'email': 'default',
                'scopes': [
                    'https://www.googleapis.com/auth/monitoring.write'
                ],
            }]
        }
    }
    if (prop['externalIP'] != 'None') and (
            'Manual Configuration' != prop['installationType']):
        gw['properties']['serviceAccounts'][0]['scopes'].append(
            'https://www.googleapis.com/auth/cloudruntimeconfig')
        resources.append({
            'name': deployment_config,
            'type': 'runtimeconfig.v1beta1.config',
            'properties': {
                'config': deployment_config,
                'description': ('Holds software readiness status '
                                'for deployment {}').format(deployment),
            },
        })
        resources.append({
            'name': set_name_and_truncate(deployment, '-software'),
            'type': 'runtimeconfig.v1beta1.waiter',
            'metadata': {
                'dependsOn': [],
            },
            'properties': {
                'parent': '$(ref.' + deployment_config + '.name)',
                'waiter': 'software',
                'timeout': '1800s',
                'success': {
                    'cardinality': {
                        'number': 1,
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
        })
    if 'instanceSSHKey' in prop:
        gw['properties']['metadata']['items'].append(
            {
                'key': 'instanceSSHKey',
                'value': prop['instanceSSHKey']
            }
        )
    if prop['generatePassword']:
        passwd = password.GeneratePassword(12, False)
        gw['properties']['metadata']['items'].append(
            {
                'key': 'adminPasswordSourceMetadata',
                'value': passwd
            }
        )
    else:
        passwd = ''
    resources.append(gw)
    netlist = list(networks)
    if GATEWAY in tags:
        for i in range(len(netlist)):
            network = netlist[i]
            fw_rule_name_prefix = set_name_and_truncate(
                '{}-{}'.format(deployment[:23], network[:18]),
                '-allow-all-to-chkp-{}'.format(i + 1))
            firewall_rules = create_firewall_rules(
                prop, network, fw_rule_name_prefix)
            resources.extend(firewall_rules)
    elif MANAGEMENT in tags:
        for i in range(len(netlist)):
            network = netlist[i]
            source_ranges = prop['network_tcpSourceRanges']
            tcp_enabled = prop['network_enableTcp']
            gwNetwork_enabled = prop['network_enableGwNetwork']
            gwNetwork_source_range = prop['network_gwNetworkSourceRanges']
            if source_ranges and not tcp_enabled:
                raise Exception(
                    'Allowed source IP ranges for TCP traffic are provided '
                    'but TCP not marked as allowed')
            if tcp_enabled and not source_ranges:
                raise Exception('Allowed source IP ranges for TCP traffic'
                                ' are required when installing '
                                'a management server')
            if not gwNetwork_enabled and gwNetwork_source_range:
                raise Exception('Gateway network source IP are provided but '
                                'not marked as allowed.')
            if gwNetwork_enabled and not gwNetwork_source_range:
                raise Exception('Gateway network source IP is required in'
                                ' MGMT deployment.')
            ranges_list = source_ranges.split(',')
            gw_network_list = gwNetwork_source_range.split(',')
            ranges = []
            gw_net_ranges = []
            for source_range in ranges_list:
                ranges.append(source_range.replace(" ", ""))
            for gw_net_range in gw_network_list:
                gw_net_ranges.append(gw_net_range.replace(" ", ""))
            if tcp_enabled:
                if gwNetwork_enabled:
                    resources.append({
                        'type': 'compute.v1.firewall',
                        'name': set_name_and_truncate(
                            '{}-{}'.format(deployment[:23], network[:18]),
                            '-gateways-to-management-{}'.format(i + 1)),
                        'properties': {
                            'network': 'global/networks/' + network,
                            'sourceRanges': list(set(gw_net_ranges + ranges)),
                            'sourceTags': [GATEWAY],
                            'targetTags': [uid],
                            'allowed': [
                                {
                                    'IPProtocol': 'tcp',
                                    'ports': ['257', '18191', '18210', '18264']
                                },
                            ],
                        }
                    })
                resources.append({
                    'type': 'compute.v1.firewall',
                    'name': set_name_and_truncate(
                        '{}-{}'.format(deployment[:23], network[:18]),
                        '-allow-gui-clients-{}'.format(i + 1)),
                    'properties': {
                        'network': 'global/networks/' + network,
                        'sourceRanges': list(set(ranges)),
                        'targetTags': [uid],
                        'allowed': [
                            {
                                'IPProtocol': 'tcp',
                                'ports': ['22', '443', '18190', '19009']
                            },
                        ],
                    }
                })
            fw_rule_name_prefix = set_name_and_truncate(
                '{}-{}'.format(deployment[:23], network[:18]),
                '-allow-all-to-chkp-{}'.format(i + 1))
            firewall_rules = create_firewall_rules(
                prop, network, fw_rule_name_prefix, True, uid)
            resources.extend(firewall_rules)
    outputs += [
        {
            'name': 'deployment',
            'value': deployment
        },
        {
            'name': 'project',
            'value': context.env['project']
        },
        {
            'name': 'vmName',
            'value': vm_name,
        },
        {
            'name': 'vmId',
            'value': '$(ref.%s.id)' % vm_name,
        },
        {
            'name': 'vmSelfLink',
            'value': '$(ref.%s.selfLink)' % vm_name,
        },
        {
            'name': 'hasMultiExternalIPs',
            'value': 0 < len(external_ifs) and external_ifs != [0],
        },
        {
            'name': 'additionalExternalIPs',
            'value': ', '.join([('$(ref.{}.networkInterfaces[{}].' +
                                 'accessConfigs[0].natIP)').format(
                vm_name, ifnum) for ifnum in external_ifs if ifnum])
        },
        {
            'name': 'vmInternalIP',
            'value': '$(ref.%s.networkInterfaces[0].networkIP)' % vm_name,
        },
        {
            'name': 'password',
            'value': passwd
        }
    ]
    return common.MakeResource(resources, outputs)
