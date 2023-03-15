# vWAN automatic configuration script

## Before begin:

*Ensure that management has a valid license.

*Configuring your server to accept connections from all IPs:
It is necessary to configure the Management Server or Multi-Domain Management Server to accept API requests.
When connected via ssh, run:

* On Management Server:

    mgmt_cli -r true set api-settings accepted-api-calls-from "All IP addresses" --domain 'System Data' ; api reconf

* On MDS:

   mgmt_cli -r true set api-settings accepted-api-calls-from "All IP addresses" ; api reconf

*Fill the vWAN_automation_config.json file with the required  fields


### To run the script:

 from a command line nevigate to vWAN configuration script folder and run:

    python vWan_automation.py







  
