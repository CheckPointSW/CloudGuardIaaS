#!/bin/bash
set -e

exec 1>/var/log/alicloud-user-data.log 2>&1

echo -e "\nStarting user data...\n"

echo "Updating cloud-version file"
template="cluster"
cv_path="/etc/cloud-version"
if test -f $cv_path; then
  echo "template_name: $template" >> $cv_path
  echo "template_version: __VERSION__" >> $cv_path
  echo "template_type: terraform" >> $cv_path
fi
cv_json_path="/etc/cloud-version.json"
cv_json_path_tmp="/etc/cloud-version-tmp.json"
if test -f $cv_json_path; then
   cat $cv_json_path | jq '.template_name = "'"$template"'"' | jq '.template_version = "__VERSION__"' | jq '.template_type = "terraform"' > $cv_json_path_tmp
   mv $cv_json_path_tmp $cv_json_path
fi

eth0_details=$(/sbin/ifconfig eth0 | grep "inet addr:" | awk "1")
ip=($(echo $eth0_details | cut -d" " -f2 | cut -d":" -f2))
oct1=$(echo $ip | tr "." " " | awk '{ print $1 }')
oct2=$(echo $ip | tr "." " " | awk '{ print $2 }')
oct3=$(echo $ip | tr "." " " | awk '{ print $3 }')
oct4=$(echo $ip | tr "." " " | awk '{ print $4 }')
hex_cluster_ip=$(printf '%02X' $oct1 $oct2 $oct3 $oct4)
HEX_IP_ADDR_LOWER="$(echo $hex_cluster_ip | tr '[A-Z]' '[a-z]')"
echo "aws_cross_az_private_member_ip=0x$HEX_IP_ADDR_LOWER" >> $FWDIR/boot/modules/fwkern.conf

echo "Set admin password"
pwd_hash='${PasswordHash}'
if [[ -n $pwd_hash ]]; then
  clish -c "set user admin password-hash $pwd_hash" -s
else
  echo "Generating random password hash"
  pwd_hash="$(dd if=/dev/urandom count=1 2>/dev/null | sha1sum | cut -c -28)"
  clish -c "set user admin password-hash $pwd_hash" -s
fi

echo "Configuring user admin shell to ${Shell}"
clish -c "set user admin shell ${Shell}" -s

ntp1=${NTPPrimary}
ntp2=${NTPSecondary}

if [[ -n $ntp1 ]]; then
  echo "Setting primary NTP server to $ntp1"
  clish -c "set ntp server primary $ntp1 version 4" -s
  if [[ -n $ntp2 ]]; then
    echo "Setting secondary NTP server to $ntp2"
    clish -c "set ntp server secondary $ntp2 version 4" -s
  fi
fi


hostname=${Hostname}
if [[ -n "${Hostname}" ]]; then
  echo "Setting hostname to $hostname"
  clish -c "set hostname $hostname" -s
fi


mgmt_ip_addr=${ManagementIpAddress}
if [[ -n $mgmt_ip_addr ]]; then
  eth1_bc_ip="$(ipcalc -b $(ip a l eth1 | awk '/inet/ {print $2}') |  cut -f2 -d=)"
  # AliCloud reserves 3 last IPs - Use 3rd last ip for nexthop address
  # e.g. for eth1_bc_ip=10.0.2.255 --> calculate eth1_nexthop_ip=10.0.2.253
  last_octet=$(echo $eth1_bc_ip | sed 's|.*\.||')
  new_last_octet="$(($last_octet-2))"
  eth1_nexthop_ip=$(echo $eth1_bc_ip | sed 's|\(.*\)\..*|\1\.|')$new_last_octet

  echo "Setting static-route to $mgmt_ip_addr via eth1"
  clish -c "set static-route $mgmt_ip_addr/32 nexthop gateway address $eth1_nexthop_ip on" -s
fi


echo "Starting First Time Wizard"
if [ "${cluster_new_config}" = "1" ]; then
  file_name="/etc/.blink_cloud_mode"
  > file_name
fi
blink_config -s "gateway_cluster_member=true&ftw_sic_key='${SICKey}'&upload_info=${AllowUploadDownload}&download_info=${AllowUploadDownload}&admin_hash='$pwd_hash'"


echo "Setting LocalGatewayExternal dynamic object"
addr_ex="$(ip addr show dev eth0 | awk '/inet/{print $2; exit}' | cut -d / -f 1)"
dynamic_objects -n LocalGatewayExternal -r "$addr_ex" "$addr_ex" -a || true
echo "Setting LocalGatewayInternal dynamic object"
addr_int="$(ip addr show dev eth2 | awk '/inet/{print $2; exit}' | cut -d / -f 1)"
dynamic_objects -n LocalGatewayInternal -r "$addr_int" "$addr_int" -a || true

if [[ -n "${GatewayBootstrapScript}" ]]; then
    echo "Running Bootstrap commands"
    eval "${GatewayBootstrapScript}"
fi

echo "Rebooting..."
shutdown -r now
