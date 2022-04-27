#!/bin/bash

generatePassword="$(echo ${generatePassword} | tr 'TF' 'tf')"
allowUploadDownload="${allowUploadDownload}"

echo "template_name: ${templateName}" >> /etc/cloud-version
echo "template_version: ${templateVersion}" >> /etc/cloud-version
function get_router() {
    local interface="$1"
    local subnet_router_meta_path="computeMetadata/v1/instance/network-interfaces/$interface/gateway"
    local router="$(get-cloud-data.sh $subnet_router_meta_path)"
    echo "$router"
}

function set_mgmt_if() {
    mgmtNIC="${mgmtNIC}"
    local mgmt_int="eth0"
    if [ "X$mgmtNIC" == "XEphemeral Public IP (eth0)" ]
    then
        mgmt_int="eth0"
    elif [ "X$mgmtNIC" == "XPrivate IP (eth1)" ]
    then
        mgmt_int="eth1"
    fi
    local set_mgmt_if_out="$(clish -s -c "set management interface $mgmt_int")"
    echo "$set_mgmt_if_out"
}

function set_internal_static_routes() {
    local private_cidrs='10.0.0.0/8 172.16.0.0/12 192.168.0.0/16'
    #Define interface for internal networks and configure
    local interface="$internalInterfaceNumber"
    local router=$(get_router $interface)
    clish -c 'lock database override'
    #Configure static routes destined to internal networks, defined in the RFC 1918, through the  internal interface
    for cidr in $private_cidrs; do
        echo "setting route to $cidr via gateway $router"
        echo "running  clish -c 'set static-route $cidr nexthop gateway address $router on' -s"
        clish -c "set static-route $cidr nexthop gateway address $router on" -s
    done
}

function create_dynamic_objects() {
    local is_managment="$1"
    local interfaces='eth0 eth1'
    for interface in $interfaces; do
        if $is_managment; then
            dynamic_objects -n "LocalGateway"
            dynamic_objects -n "LocalGatewayExternal"
            dynamic_objects -n "LocalGatewayInternal"
        else
            local addr="$(ip addr show dev $interface | awk "/inet/{print \$2; exit}" | cut -d / -f 1)"
            if [ "$interface" == "eth0" ]; then
                dynamic_objects -n "LocalGateway" -r "$addr" "$addr" -a
                dynamic_objects -n "LocalGatewayExternal" -r "$addr" "$addr" -a
            else
                dynamic_objects -n "LocalGatewayInternal" -r "$addr" "$addr" -a
            fi
        fi
    done
}


function post_status() {
    local is_success="$1"
    local need_boot="$2"
    local status
    local value
    local instance_id

    if "${hasInternet}"
    then
        if "$is_success"
        then
            status="success"
            value="Success"
        else
            status="failure"
            value="Failure"
        fi
        instance_id="$(get-cloud-data.sh computeMetadata/v1/instance/id)"
        cat <<EOF >/etc/software-status
        $FWDIR/scripts/gcp.py POST "${config_url}/variables" \
            --body '{
                "name": "${config_path}/variables/status/$status/$instance_id",
                "value": "$(echo $value | base64)"
            }'
EOF
    fi

    create_dynamic_objects $installSecurityManagement

    if "$installSecurityGateway"
    then

        set_internal_static_routes
        set_mgmt_if

        ##########
        # DA Self update

        DAselfUpdateHappening=$(dbget installer:self_update_in_progress)
        if [ "X$DAselfUpdateHappening" == "X1" ]
        then
            oldDApid=$(pidof DAService)
            countdown=121
            while [ $((--countdown)) -gt 0 ]
            do
                sleep 1
                DApid=$(pidof DAService)

                if [ "$(DApid:-$oldDApid)" -ne "$oldDApid" ]
                then
                    break
                fi
            done
            if [ $countdown -eq 0 ]
            then
                dbset installer:self_update_in_progress
            fi
        fi

        ##########
    fi

    if [ "$installSecurityManagement" -a "Management only" = "${installationType}" ]
    then
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
        uid="$(echo "$uid" | cut -c 2- | rev | cut -c 2- | rev)"

        if [ ! -z "$public_ip" ] && [ ! -z "$uid" ]
        then
            mgmt_cli -r true set-generic-object uid "$uid" ipaddr "$public_ip"
        fi
    fi

    if "$need_boot"
    then
        if [ "${enableMonitoring}" = "True" ]
        then
            chkconfig --add gcp-statd
        fi
        shutdown -r now
    else
        service gcpd restart
        if [ "${enableMonitoring}" = "True" ]
        then
            chkconfig --add gcp-statd
            service gcp-statd start
        fi
    fi
}
clish -c 'set user admin shell ${shell}' -s

case "${installationType}" in
"Gateway only")
    installSecurityGateway=true
    gatewayClusterMember=false
    installSecurityManagement=false
    sicKey="${computed_sic_key}"
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
    sicKey="${sicKey}"
    internalInterfaceNumber=2
    ;;
"AutoScale")
    installSecurityGateway=true
    gatewayClusterMember=false
    installSecurityManagement=false
    sicKey="${computed_sic_key}"
    internalInterfaceNumber=1
    ;;
esac

conf="install_security_gw=$installSecurityGateway"
if $installSecurityGateway
then
    conf="$conf&install_ppak=true"
    blink_conf="gateway_cluster_member=$gatewayClusterMember"
fi
conf="$conf&install_security_managment=$installSecurityManagement"
if $installSecurityManagement
then
    if "$generatePassword"
    then
        managementAdminPassword="$(get-cloud-data.sh \
            computeMetadata/v1/instance/attributes/adminPasswordSourceMetadata)"
        conf="$conf&mgmt_admin_name=admin"
        conf="$conf&mgmt_admin_passwd=$managementAdminPassword"
    else
        conf="$conf&mgmt_admin_radio=gaia_admin"
    fi

    managementGUIClientNetwork="${managementGUIClientNetwork}"
    conf="$conf&install_mgmt_primary=true"

    if [ "0.0.0.0/0" = "$managementGUIClientNetwork" ]
    then
        conf="$conf&mgmt_gui_clients_radio=any"
    else
        conf="$conf&mgmt_gui_clients_radio=network"
        ManagementGUIClientBase="$(echo $managementGUIClientNetwork | \
            cut -d / -f 1)"
        ManagementGUIClientMaskLength="$(echo $managementGUIClientNetwork | \
            cut -d / -f 2)"
        conf="$conf&mgmt_gui_clients_ip_field=$ManagementGUIClientBase"
        conf="$conf&mgmt_gui_clients_subnet_field=$ManagementGUIClientMaskLength"
    fi

fi

blink_conf="$blink_conf&ftw_sic_key=$sicKey"
blink_conf="$blink_conf&download_info=$allowUploadDownload"
blink_conf="$blink_conf&upload_info=$allowUploadDownload"

conf="$conf&$blink_conf"
if "$generatePassword"
then
    blink_password="$(get-cloud-data.sh \
        computeMetadata/v1/instance/attributes/adminPasswordSourceMetadata)"
else
    blink_password="$(dd if=/dev/urandom count=1 \
        2>/dev/null | sha256sum | cut -c -28)"
fi
blink_conf="$blink_conf&admin_password_regular=$blink_password"

if [ "Gateway only" = "${installationType}" ] || [ "Cluster" = "${installationType}" ] || [ "AutoScale" = "${installationType}" ]
then
    config_cmd="blink_config -s $blink_conf"
else
    config_cmd="config_system -s $conf"
fi

if $config_cmd
then
    if "$installSecurityManagement"
    then
        post_status true "$installSecurityGateway"
    elif [ "Cluster" = "${installationType}" ]
    then
        mgmt_subnet_gw="$(get-cloud-data.sh computeMetadata/v1/instance/network-interfaces/1/gateway)"
        sed -i 's/__CLUSTER_PUBLIC_IP_NAME__/'"${primary_cluster_address_name}"'/g' /etc/fw/conf/gcp-ha.json
        sed -i 's/__SECONDARY_PUBLIC_IP_NAME__/'"${secondary_cluster_address_name}"'/g' /etc/fw/conf/gcp-ha.json
        clish -c 'set static-route '"${managementNetwork}"' nexthop gateway address '"$mgmt_subnet_gw"' on' -s
        post_status true true
    else
        post_status true false
    fi
else
    post_status false false
fi
