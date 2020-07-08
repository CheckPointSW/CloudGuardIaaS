#!/bin/bash

exec 1>/var/log/aws-user-data.log 2>&1

echo template_name: TAP_tf >> /etc/cloud-version
echo template_version: 20200413 >> /etc/cloud-version

hname="CP-TAP"
instance_id="$(curl_cli -s -S 169.254.169.254/latest/meta-data/instance-id)"

printf H4sIAEQeOVoCAzNoYuE3aGL6voCZiZGJiZHBgJeNU6vNo+07LyMjKyuDQYYhtwEnG3MoC5swU2iwoaqBMojDJSwTXJJYlJaZmpOiEJKanJGXn5OfnplarKPgmZesZ2hkYABSxi2siVDmnJNYXKxgpOCcWlSSmZaZnFiSmZ+n4FhakpFflFlSaSAnzmtgYmBmZGlobmxpaBYlzmuMzKWjS5oYFZCDgZGVgbmJkZcBKM7B1MTIyLDd6MS/l4XLWFrX8gim3D/n+/4Es0S7/cLVv22Wzf9weOGtKzfytIMn/FZZYtfyYd6L+DdP1V2+aiyzr773QOvDifXB+vNOsTJOlutPk7Fc7vsralsxi2ra6/L655HHvGaqioS8Vjv+uV7yqkFB//oNblr/177WfHt9/iqW9sVXfnYuNYm/7Tyxyexmms3GHTub/s6xshM4Yf2eLTWtarakhO3/wkAbA734fbblxZti2XIOK4fN0m5VmySznGnzE3ve9RyVTTvMbF/NuWy6eU/mqa9n5r74m9Ir3mCcF+cVO/OkXPuWuVIHruYJmyrH3Z8db/v+2veyQ6/sdlfwyjilZ7Pc+HHtVn73J5cFjKuZGJkXNx41aDxkIAsMW1k+FjEWkf3x2y+euyvf9iU6dM2d6wKH+FZ2PDdonASSV2Zp7DJobG/AqmZhzpIs+kVtEzCB84DcJMzCasDMyPgfLbkzg6KXda59x9yLJ6VCF67J/Pw58tZsxnYp//CVCys5tW5/198kd+Z4XNaN5vaF0997mtqVszlGJO3vi9jBlW7/ZvNdxTT5kyG/is7Y+jjcaFxfPq+5avei419NxPtuCjp8+aOj5StavzwpVk/1MgO3gpRsxk/xHV/2dr/ViLzrK9Yt3nxiU+px3aqlq/YEt+XeDV9y6oeCI3fGhy+/S/aFxVZVfv0p2/pYd+q+r4UTnM/0ys9i4GrXfBmqFMGg/OqxkLNmtDvH3R7HrFS2FU8VVzlumao4dWftRZPVwtfW7rnzyNby7F670oKFEpHMJ5W29M+5Gqd1fem2K1y5P7Y7CLrNkq/kS9rPP/3NA3158SkAHEuNARMEAAA= | base64 -d | gunzip -c | cpopenssl x509 -inform DER >"$CPDIR/tmp/wait-handle.crt"
cat "$CPDIR/conf/ca-bundle.crt" >>"$CPDIR/tmp/wait-handle.crt"

echo "Generating SIC password"
sic=$(tr -dc "0-9a-zA-Z" < /dev/urandom | head -c 8)

blink_config -s "hostname='$hname'&gateway_cluster_member=false&ftw_sic_key='$sic'&upload_info=true&download_info=true"
rc=$?

echo "Pulling NOW install script..."
INSTALLER=/var/log/now_installer

runtime="10 minute"
endtime=$(date -ud "$runtime" +%s)

while [[ $(date -u +%s) -le $endtime ]]
do
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
