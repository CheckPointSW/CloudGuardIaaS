#!/bin/bash

exec 1>/var/log/aws-user-data.log 2>&1

echo template_name: TAP_tf >> /etc/cloud-version
echo template_version: 20210309 >> /etc/cloud-version
echo template_type: terraform >> $cv_path

hname="CP-TAP"

echo "Generating SIC password"
sic=$(tr -dc "0-9a-zA-Z" < /dev/urandom | head -c 8)

blink_config -s "hostname='$hname'&gateway_cluster_member=false&ftw_sic_key='$sic'&upload_info=true&download_info=true"
rc=$?

echo "Pulling NOW install script..."
INSTALLER=/var/log/now_installer

runtime="10 minute"
endtime=$(date -ud "$runtime" +%s)

while [[ $(date -u +%s) -le $endtime ]]; do
    curl_cli -s -S --cacert "$CPDIR/conf/ca-bundle.crt" https://portal.now.checkpoint.com/static/configure.aws.sh -o $INSTALLER && break
    sleep 2
done

chmod +x $INSTALLER
dos2unix $INSTALLER
$INSTALLER ${RegistrationKey} ${VxlanIds} >& $FWDIR/log/now_installer.elg

LOADER=$FWDIR/bin/loadInstaller
echo '' > $LOADER
chmod +x "$LOADER"

cpwd_admin start -name NOW_HF_LOADER -path "$LOADER" -command loadInstaller -slp_timeout 5 -retry_limit 10
echo "done"
