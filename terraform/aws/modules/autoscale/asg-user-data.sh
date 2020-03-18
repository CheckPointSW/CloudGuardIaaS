#!/bin/bash
set -e

exec 1>/var/log/aws-user-data.log 2>&1

echo -e "\nStarting user data...\n"

echo template_name: autoscale_tf >> /etc/cloud-version
echo template_version: 20200318 >> /etc/cloud-version

echo "Configuring admin password hash"
if [[ -n ${PasswordHash} ]]; then
  pwd_hash="${PasswordHash}"
else
  echo "Generating random password"
  pwd_hash="$(dd if=/dev/urandom count = 1 2>/dev/null | sha1sum | cut -c -28)"
fi
clish -c "set user admin password-hash $pwd_hash" -s

echo "Configuring user admin shell to ${Shell}"
clish -c "set user admin shell ${Shell}" -s

echo "Running FTW..."
blink_config -s "gateway_cluster_member=false&ftw_sic_key='${SICKey}'&upload_info=${AllowUploadDownload}&download_info=${AllowUploadDownload}&admin_hash='$pwd_hash'"

echo "Configuring dynamic objects"
addr="$(ip addr show dev eth0 | awk '/inet/{print $2; exit}' | cut -d / -f 1 | sed -e 's/[^0-9.]*//')"
dynamic_objects -n LocalGateway -r "$addr" "$addr" -a || true


if ${EnableCloudWatch}; then
  echo "Starting cloudwatch"
  cloudwatch start
fi


if [[ -n "${BootstrapScript}" ]]; then
  echo "Running Bootstrap commands"
  eval "${BootstrapScript}"
fi
echo -e "\nFinished user data"