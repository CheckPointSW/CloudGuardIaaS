#!/bin/bash

# The script collects Central Licenses debug files for troubleshooting purposes.

# Instructions : 
	# If you have MDS environment and uses license in domain mode - please run the script with -d <DOMAIN_NAME>
	# If your environment acceseses the internet using a configured proxy - please run the script with -p <IP_or_HostName:Port>
	# Otherwise , run the script directly . 
	
# Written by: Check Point Software Technologies LTD. 
# For additional information please refer to CloudGuard Network Central License Tool Administration Guide.

# Licenses_Collector - version 3

usage()
{
  echo "Usage: `basename $0` [-p IP_or_HostName:port] [-d domain] [-h]"
  echo "output_file: Will be a tar.gz file"
  echo "proxy: To be used when checking connectivity with usercenter only"
  echo "domain: To be used only on MDS environment. The domain name taken from 'mdsstat'"
}

while getopts "p:d:h" opt; do
	case "$opt" in
	    d)
	      DOMAIN_NAME="$OPTARG"
          ;;
		p)
		  PROXY_PORT="$OPTARG"
		  ;;
		h)
		  usage
		  exit 0
		  ;;
		*)
		  usage 
		  exit 1
	esac
done


BASEPATH=$VSECDIR
TMPPATH=$BASEPATH/tmp
OUTPUTFILE_NAME=vsec___data.tar
CURL_CLI=curl_cli
USERCENTER=https://usercenter.CheckPoint.com

log_msg()
{
	echo "$(date)  $1"
}

log_msg "Starting"
log_msg "  Creating $TMPPATH"
\rm -rf $TMPPATH
mkdir -p $TMPPATH

if [ -n "$DOMAIN_NAME" ]; then
  log_msg "  switch to domain env"
  mdsenv "$DOMAIN_NAME"
fi

# checking if there's connectivity with userCenter and if TCP port 18208 is open
log_msg "  Checking if TCP port 18208 is open and accessible"
printf "								Checking TCP port \n\n" >> $TMPPATH/Sync
netstat -na | grep "18208" >> $TMPPATH/Sync
printf "\n\n" >> $TMPPATH/Sync


printf "								Checking connecitivty with userCenter\n\n" >> $TMPPATH/Sync

if [ -n "$PROXY_PORT" ]; then
	log_msg "  Checking connecitivty with userCenter using proxy"
	$CURL_CLI --proxy $PROXY_PORT -v -k $USERCENTER &>> $TMPPATH/Sync
else
	log_msg "  Checking connecitivty with userCenter without using proxy"
	$CURL_CLI -v -k $USERCENTER &>> $TMPPATH/Sync 
fi
	
printf "the exit code is : %s\n" $? >> $TMPPATH/Sync

# Collect server logs (cpm.elg*) data
log_msg "  Copying $MDS_FWDIR/log/cpm.elg* into $TMPPATH"
cp $MDS_FWDIR/log/cpm.elg* $TMPPATH

#Collect client logs (vseclic.elg*) data
log_msg "  Copying $MDS_FWDIR/log/vseclic.elg* into $TMPPATH"
cp $MDS_FWDIR/log/vseclic.elg* $TMPPATH

# Collect licenses data from DB
log_msg "  Collecting licenses with cprlic into $TMPPATH"
cprlic print -all -x -a >> $TMPPATH/Attached_licenses

log_msg "  Collecting vsec view into $TMPPATH"
vsec_lic_cli view >> $TMPPATH/View_licenses.txt

log_msg "  Collecting management licenses into $TMPPATH"
cplic print -n -x >> $TMPPATH/Management_licenses.txt

log_msg "  Collecting licensepool_data DB into $TMPPATH"
psql_client cpm postgres -c "select * from licensePool_data;" >> $TMPPATH/licensePoolData.txt

log_msg "  Collecting GatewayLicenses_data DB into $TMPPATH"
psql_client cpm postgres -c "select * from GatewayLicenses_data;" >> $TMPPATH/GatewayLicensesData.txt

log_msg "  Compressing $TMPPATH into $OUTPUTFILE_NAME"
tar -cvf $OUTPUTFILE_NAME $TMPPATH > /dev/null 2>&1

log_msg "  Cleaning up $TMPPATH"
rm -rf $TMPPATH

log_msg "  Done. $OUTPUTFILE_NAME is ready"
