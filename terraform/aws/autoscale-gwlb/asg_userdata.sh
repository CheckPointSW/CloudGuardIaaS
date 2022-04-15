#!/bin/bash
set -e

exec 1>/var/log/aws-user-data.log 2>&1

echo -e "\nStarting user data...\n"

echo "Updating cloud-version file"
template="autoscale_gwlb"
cv_path="/etc/cloud-version"
if test -f $cv_path; then
  echo "template_name: $template" >> $cv_path
  echo "template_version: 20220414" >> $cv_path
  echo "template_type: terraform" >> $cv_path
fi
cv_json_path="/etc/cloud-version.json"
cv_json_path_tmp="/etc/cloud-version-tmp.json"
if test -f $cv_json_path; then
   cat $cv_json_path | jq '.template_name = "'"$template"'"' | jq '.template_version = "20220414"' | jq '.template_type = "terraform"' > $cv_json_path_tmp
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

if ${EnableInstanceConnect} ; then
  echo "Enabling ec2 instance connect"
  if [[ -d "/etc/ec2-instance-connect" ]]; then
    ec2-instance-connect-config on
    echo "Enabled ec2 instance connect"
  else
    echo "Could not enable eic, not supported in versions R80.30 and below"
  fi
fi

echo "Starting First Time Wizard"
blink_config -s "gateway_cluster_member=false&ftw_sic_key='${SICKey}'&upload_info=${AllowUploadDownload}&download_info=${AllowUploadDownload}&admin_hash='$pwd_hash'"

echo "Configuring dynamic objects"
addr="$(ip addr show dev eth0 | awk '/inet/{print $2; exit}' | cut -d / -f 1 | sed -e 's/[^0-9.]*//')"
dynamic_objects -n LocalGateway -r "$addr" "$addr" -a || true


if ${EnableCloudWatch}; then
  echo "Starting cloudwatch"
  echo '{\"version\":\"1\"}' > $FWDIR/conf/cloudwatch.json
  cloudwatch start
fi


if [[ -n "${BootstrapScript}" ]]; then
  echo "Running Bootstrap commands"
  eval "${BootstrapScript}"
fi
echo -e "\nFinished user data"
