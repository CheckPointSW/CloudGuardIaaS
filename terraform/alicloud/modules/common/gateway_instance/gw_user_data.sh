#!/bin/bash
set -e

exec 1>/var/log/alicloud-user-data.log 2>&1

echo -e "\nStarting user data...\n"

echo "Updating cloud-version file"
template="gateway"
cv_path="/etc/cloud-version"
if test -f $cv_path; then
  echo "template_name: $template" >> $cv_path
  echo "template_version: 20230329" >> $cv_path
  echo "template_type: terraform" >> $cv_path
fi
cv_json_path="/etc/cloud-version.json"
cv_json_path_tmp="/etc/cloud-version-tmp.json"
if test -f $cv_json_path; then
   cat $cv_json_path | jq '.template_name = "'"$template"'"' | jq '.template_version = "20230329"' | jq '.template_type = "terraform"' > $cv_json_path_tmp
   mv $cv_json_path_tmp $cv_json_path
fi

echo "Configuring admin password hash"
if [[ -n '${PasswordHash}' ]]; then
      pwd_hash='${PasswordHash}'
else
      echo "Generating random password"
      pwd_hash="$(dd if=/dev/urandom count = 1 2>/dev/null | sha1sum | cut -c -28)"
fi
clish -c "set user admin password-hash $pwd_hash" -s

echo "Configuring user admin shell to ${Shell}"
clish -c "set user admin shell ${Shell}" -s

if [[ -n "${NTPPrimary}" ]]; then
       echo "Setting primary NTP server to ${NTPPrimary}"
       clish -c "set ntp server primary ${NTPPrimary} version 4" -s
       if [[ -n "${NTPSecondary}" ]]; then
               echo "Setting secondary NTP server to ${NTPSecondary}"
               clish -c "set ntp server secondary ${NTPSecondary} version 4" -s
       fi
       clish -c "set ntp active on" -s
fi

if [[ -n "${Hostname}" ]]; then
       echo "Setting hostname to ${Hostname}"
       clish -c "set hostname ${Hostname}" -s
fi

echo "Starting First Time Wizard"
if [ "${gw_new_config}" = "1" ]; then
  file_name="/etc/.blink_cloud_mode"
  > file_name
fi
blink_config -s "gateway_cluster_member=false&ftw_sic_key='${SICKey}'&upload_info=${AllowUploadDownload}&download_info=${AllowUploadDownload}&admin_hash='$pwd_hash'"
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

echo -e "\nFinished user data"