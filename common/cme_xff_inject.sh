#! /bin/bash

# This script activates XFF injection on the gateways
# For more information about XFF injection, see https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk167578&partition=Advanced&product=Security

fw ctl set int inject_xff_header_activated 1
echo "inject_xff_header_activated=1" >> $FWDIR/modules/fwkern.conf