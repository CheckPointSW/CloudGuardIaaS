# CME API Postman
Postman is a popular API client that makes it easy for developers to create, share, test and document APIs.
</br>Postman can import and export Postman data, including collections, environments, data dumps, and globals.
## How to set CME-API environment in Postman
In order to set your Postman to use CME-API we created a data file for you to import:

### CME-API collection
1. Open Postman.
2. Click Import in the upper-left corner
   </br>(You can import your data via files, folders, links, raw text, or GitHub repositories)
4. Load the "cme_api.postman_collection.json" file and click "Import"

## How to use it
After importing the CME-API collection, click on the “cme_api” collection at the left bar and then on the “Variables” tab.
</br> You need to set the current value of “managementIP", “user” and “password” variables.
</br> If you used previously the CME_API Environment variables, please go to the Environments tab and uncheck it.

Now, for each API call you make, a login to your server will be done if needed and the session key will automatically be saved into the session variable,
<br/> All you need to do now is update body values of your requests according to your need.