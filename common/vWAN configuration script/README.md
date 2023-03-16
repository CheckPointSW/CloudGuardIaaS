# vWAN Automatic configuration script
This script was created for easy NVA gateways configuration in Smart Console by automating the process of adding the gateways objects to Smart Console, establishing SIC, disabling anti-spoofing for internal and external interfaces, and installing policy.

## Preconditions:

1. Clone or download the files in this directory.

2. Ensure that management has a valid license.

3. Configuring your server to accept connections from all IPs:
It is necessary to configure the Management Server or Multi-Domain Management Server to accept API requests.
When connected via ssh, run:

* On Management Server:
    ```
    mgmt_cli -r true set api-settings accepted-api-calls-from "All IP addresses" --domain 'System Data' ; api reconf
    ```

- On MDS:
    ```
    mgmt_cli -r true set api-settings accepted-api-calls-from "All IP addresses" ; api reconf
    ```


4. Fill the vWAN_automation_config.json file with the required data.


### Usage:

- Nevigate to vWAN configuration script folder.

- Run:
    ```
    python vWan_automation.py
    ```





  
