# CME API Postman
Postman is a popular API client that makes it easy for developers to create, share, test and document APIs.
</br>Postman can import and export Postman data, including collections, environments, data dumps, and globals.
## How to set CME-API environment in Postman
In order to set your Postman to use CME-API we created 2 data files for you to import:
### CME-API collection
1. Open Postman.
2. Click Import in the upper-left corner
   </br>(You can import your data via files, folders, links, raw text, or GitHub repositories)
4. Load the "CME_API.postman_environment.json" file of the desired collection and click "Import"

### CME-API environments
1. Open Postman.
2. Click Import in the upper-left corner
   </br>(You can import your data via files, folders, links, raw text, or GitHub repositories)
4. Load the "cme_api_v1.postman_collection.json" file of the desired environments and click "Import"

## How to use it
By importing CME-API environments, you imported to your Postman workspace 2 environments variables: server and session.
</br> First you need to set "server" variable to your MGMT public IP:
1. Click "Environment quick look" in the upper-right corner (eye logo) -> Edit
2. Change serve's value under "CURRENT VALUE" from <mgmt_ip_address> to your MGMT public IP address.

Now each time you will login to your server, the session will automatically save into session variable,
<br/> All you need to do now is update body values of your requests according to your need.