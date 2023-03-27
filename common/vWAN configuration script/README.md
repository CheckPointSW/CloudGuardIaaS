# vWAN Automatic configuration script
This script was created for easy NVA gateways configuration in Smart Console by automating the process of adding the gateways objects to Smart Console, establishing SIC, and installing policy.

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

5. For Linux users:

    Ensure Python3 installed. Run:
    ```
    python3 --version
    ```

    If Python is installed on your system, the version number will be displayed in the Command Prompt window. If Python is not installed, you will receive an error message. 

5. Install requests package:
    ```
    pip install requests
    ```


## Usage:
- Nevigate to vWAN configuration script folder.

#### **Linux:**

- Run:
    or:
    ```
    python3 vWan_automation.py
    ```
- Enter the Client Secret & SIC for the script when prompted.
- Wait for the script to finish. 
#### **Windows:**
- Right click on main.ps1 and click on “Run with PowerShell”.
    - There might be a prompt, press “y” to continue.
- Wait for any dependency to be installed (Python or “requests” package).
- Enter the Client Secret & SIC for the script when prompted.
- Wait for the script to finish.




  
