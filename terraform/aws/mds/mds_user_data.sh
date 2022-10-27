#!/bin/bash
set -e

exec 1>/var/log/aws-user-data.log 2>&1

echo -e "\nStarting user data...\n"

echo "Updating cloud-version file"
template="mds"
cv_path="/etc/cloud-version"
if test -f $cv_path; then
  echo "template_name: $template" >> $cv_path
  echo "template_version: 20210309" >> $cv_path
  echo "template_type: terraform" >> $cv_path
fi
cv_json_path="/etc/cloud-version.json"
cv_json_path_tmp="/etc/cloud-version-tmp.json"
if test -f $cv_json_path; then
  cat $cv_json_path | jq '.template_name = "'"$template"'"' | jq '.template_version = "20210309"' | jq '.template_type = "terraform"' > $cv_json_path_tmp
  mv $cv_json_path_tmp $cv_json_path
fi

primary=${IsPrimary}
secondary=${IsSecondary}

pwd_hash='${PasswordHash}'
if [[ -n $pwd_hash ]]; then
    echo "Set admin password"
    clish -c "set user admin password-hash $pwd_hash" -s
fi

if [[ -n "${Hostname}" ]]; then
       echo "Setting hostname to ${Hostname}"
       clish -c "set hostname ${Hostname}" -s
fi

if [[ -n "${NTPPrimary}" ]]; then
       echo "Setting primary NTP server to ${NTPPrimary}"
       clish -c "set ntp server primary ${NTPPrimary} version 4" -s
       if [[ -n "${NTPSecondary}" ]]; then
               echo "Setting secondary NTP server to ${NTPSecondary}"
               clish -c "set ntp server secondary ${NTPSecondary} version 4" -s
       fi
       clish -c "set ntp active on" -s
fi

if [[ "${AdminSubnet}" == "0.0.0.0/0" ]]; then
    mgmt_clients="mgmt_gui_clients_radio=any"
else
    admin_subnet_ip="$(echo ${AdminSubnet} | cut -d / -f 1)"
    admin_subnet_bits="$(echo ${AdminSubnet} | cut -d / -f 2)"
    mgmt_clients="mgmt_gui_clients_radio=network&mgmt_gui_clients_ip_field=$admin_subnet_ip&mgmt_gui_clients_subnet_field=$admin_subnet_bits"
fi

if $primary; then
  logServer=false
else
  if $secondary; then
    logServer=false
  else
    logServer=true
  fi
fi

if $primary; then
  sic=notused
else
  sic=${SICKey}
fi

echo "Starting First Time Wizard"
config_system -s "install_security_gw=false&$mgmt_clients&install_mds_primary=$primary&install_mds_secondary=$secondary&install_mlm=$logServer&install_mds_interface=eth0&mgmt_admin_radio=gaia_admin&ftw_sic_key='$sic'&download_info=${AllowUploadDownload}&upload_info=${AllowUploadDownload}"

echo "Configuring user admin shell to ${Shell}"
clish -c "set user admin shell ${Shell}" -s

if $primary; then
  until mgmt_cli -r true discard; do
  sleep 30
  done
fi

echo "Running service autoprovision start..."

if ${EnableInstanceConnect}; then
    if [ -d "/etc/ec2-instance-connect" ]; then
        echo "Enabling ec2 instance connect"
        ec2-instance-connect-config on
    else
        echo "Could not enable eic, not supported in versions R80.30 and below"
    fi
fi

if [[ -n "${BootstrapScript}" ]]; then
    echo "Running Bootstrap commands"
    eval "${BootstrapScript}"
fi
echo -e "\nFinished user data"