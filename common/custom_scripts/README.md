# Custom Scripts
This folder contains custom scripts that can be uploaded in the "Bootstrap scripts" option when deploying a resource via a template.

---
## password_script.sh - Password Change Script

This script is designed to be used on Check Point's solutions that do not have the option to add a password for the Gaia machine.  
It allows you to configure the desired password for logging in to the Gaia Portal, it will be run during the deployment process.

### Usage
 
To use this script, follow these steps: 
1. Get the desired password hash by running the following command: `openssl passwd -6 YOUR_PASSWORD` change `YOUR_PASSWORD` to the designed password.
2. Edit the script file and replace the placeholder "<YOUR_HASHED_PASSWORD>" with the hash value from step 1.
3. Save the modified script file. 
4. Upload the script file to the "Bootstrap script" option during the deployment process. 

The script will be executed during the deployment process, and the specified password will be set for logging in to the Gaia Portal

---

