# Copyright 2016 Check Point Software LTD.

import common
import default
import images
import password


GATEWAY = 'checkpoint-gateway'
PROJECT = 'checkpoint-public'
LICENSE = 'byol'
LICENCE_TYPE = 'mig'

VERSIONS = {
    'R80.30-GW': 'r8030-gw',
    'R80.40-GW': 'r8040-gw',
    'R81-GW': 'r81-gw'
}

TEMPLATE_NAME = 'autoscale'
TEMPLATE_VERSION = '20201028'

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
    fw_rule_name = '%s-%s-%s' % (deployment, net_name, protocol)
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
                             gw_version=VERSIONS['R80.30-GW']):
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
    return instance_template


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
    cpu_usage = float(cpu_usage)/100
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

    version_chosen = prop['autoscalingVersion'].split(' ')[0]+"-GW"
    nics = create_nics(context)
    gw_template = create_instance_template(context,
                                           prop['deployment'],
                                           nics,
                                           depends_on=prop['gw_dependencies'],
                                           gw_version=VERSIONS[version_chosen])
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
            'value': str(int(prop['cpuUsage']))+'%'
        },
        {
            'name': 'minInstancesInt',
            'value': str(int(prop['minInstances']))
        },
        {
            'name': 'maxInstancesInt',
            'value': str(int(prop['maxInstances']))
        },
    ]

    return common.MakeResource(prop['resources'], prop['outputs'])
