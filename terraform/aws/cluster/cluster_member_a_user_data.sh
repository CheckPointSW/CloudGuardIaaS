#!/bin/bash
set -e

exec 1>/var/log/aws-user-data.log 2>&1

echo -e "\nStarting user data...\n"

echo "Updating cloud-version file"
template="cluster"
cv_path="/etc/cloud-version"
if test -f $cv_path; then
  echo "template_name: $template" >> $cv_path
  echo "template_version: 20210309" >> $cv_path
fi
cv_json_path="/etc/cloud-version.json"
cv_json_path_tmp="/etc/cloud-version-tmp.json"
if test -f $cv_json_path; then
   cat $cv_json_path | jq '.template_name = "'"$template"'"' | jq '.template_version = "20210309"' > $cv_json_path_tmp
   mv $cv_json_path_tmp $cv_json_path
fi

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

if ${AllocateAddress}; then
  eip=${MemberAPublicAddress}
else
  eip=""
fi

if [[ -n $eip ]]; then
  echo "Resetting alias ip"
  clish -c "delete interface eth0 alias eth0:1" -s || true
  clish -c "add interface eth0 alias $eip/32" -s
fi

hostname=${Hostname}
if [[ -n "${Hostname}" ]]; then
  hostname+="-member-a"
  echo "Setting hostname to $hostname"
  clish -c "set hostname $hostname" -s
fi


echo "Starting First Time Wizard"
blink_config -s "gateway_cluster_member=true&ftw_sic_key='${SICKey}'&upload_info=${AllowUploadDownload}&download_info=${AllowUploadDownload}&admin_hash='$pwd_hash'"

if ${EnableInstanceConnect}; then
    if [ -d "/etc/ec2-instance-connect" ]; then
        echo "Enabling ec2 instance connect"
        ec2-instance-connect-config on
    else
        echo "Could not enable eic, not supported in versions R80.30 and below"
    fi
fi

echo "Setting LocalGatewayExternal dynamic object"
addr_ex="$(ip addr show dev eth0 | awk '/inet/{print $2; exit}' | cut -d / -f 1)"
dynamic_objects -n LocalGatewayExternal -r "$addr_ex" "$addr_ex" -a || true
echo "Setting LocalGatewayInternal dynamic object"
addr_int="$(ip addr show dev eth1 | awk '/inet/{print $2; exit}' | cut -d / -f 1)"
dynamic_objects -n LocalGatewayInternal -r "$addr_int" "$addr_int" -a || true

if [[ -n "${GatewayBootstrapScript}" ]]; then
    echo "Running Bootstrap commands"
    eval "${GatewayBootstrapScript}"
fi

echo "Rebooting..."
shutdown -r now