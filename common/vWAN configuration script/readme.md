# vWAN Automatic configuration script
This script was created for easy NVA gateways configuration in Smart Console by automating the process of adding the gateways objects to Smart Console, establishing SIC, and installing policy.

## Preconditions:

1. Clone or download WAN_automatic_script.py file in this directory.

2. Ensure that management has a valid license and has CME take 227 and above.


## Usage:
- Copy the vWAN_automatic_script.py file to /opt/CPcme/menu on the management.


- Run:
    ```
    python3 vWAN_automatic_script.py "tanant="<Active-Directory-Tenant-ID>"" "client_id="<Client-ID>"" "client_secret="<Client-Secret>"" "subscription="<Azure-Subscription>"" "managedAppResourceGroupName="<Managed-App-Resource-Group-Name>"" "nvaName="<NVA-name>"" "sic_key="<SIC-key>"" "policy="<Policy-Name>""
    ```

### Example:
python3 vWAN_automatic_script.py "tanant="7113cebb-911c-4122-aa5c-34db449380f7"" "client_id="82fb1445-f40e-46dc-9cd3-c065e14f132b"" "client_secret="xxx="" "subscription="98e34f37-ece4-4cdc-97dc-44a074f84aff"" "managedAppResourceGroupName="mrg-vwan-managed-app-12340424143321"" "nvaName="nvaGw"" "sic_key="SIC123456"" "policy="Standard""

- Wait for the script to finish. 
