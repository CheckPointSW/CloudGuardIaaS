# CFWaaS API Postman

Postman is an API client that makes it easy to create, share, test and document APIs. It can import
and export collections, environments and variables as data files.

This directory ships the Check Point **Cloud Firewall as a Service** (CFWaaS) API as a single
self-contained Postman collection: `cfwaas_api.postman_collection.json`. It covers 7 requests across the managed
firewall deployment lifecycle - listing deployments, reading their gateways and traffic metrics, and
creating new ones on AWS, Azure and GCP.

## Importing the collection

1. Open Postman.
2. Click **Import** in the upper-left corner. You can import via files, folders, links, raw text or
   Git repositories.
3. Select `cfwaas_api.postman_collection.json` and click **Import**.

There is no separate environment file to import. Every URL, token and header is derived by the
collection itself.

## Creating an API key

1. Sign in to the [Check Point Portal](https://portal.checkpoint.com/) for your region.
2. Go to **Global Settings → API Keys** and create a key with the **User** service.
3. Give it the role the requests you intend to send need - **Read Only** is enough to list
   deployments and read metrics, **Admin** is required to create one.
4. Copy the **Client ID** and the **Secret Key**, and paste the Secret Key straight into the Postman
   Vault as described below. **The portal shows it once and never again** - if you lose it, the only
   way forward is a new key.

A key is issued per tenant per region. A key created in one region is rejected by every other, so
create it in the same region you will point the collection at - one of the regions listed under
[Choosing your region](#choosing-your-region).

## Setting your credentials

Credentials go in the **Postman Vault**, not in a variable. The Vault is local to your machine and is
never synced to Postman's cloud or included in an export, which means a collection you export or
share can never carry your key.

1. Click the **Vault** icon at the bottom-left of Postman and unlock it.
2. Add `cfwaas-client-id` with your Client ID.
3. Add `cfwaas-access-key` with your Secret Key.
4. When Postman asks whether this collection may read the Vault, allow it.

## Choosing your region

Cloud Firewall as a Service is available in the regions below and nowhere else. Click the collection
in the left sidebar, open the **Variables** tab, and set the **current value** of `region` to one of
these exact values - they are case-sensitive:

| Value | Data centre |
| --- | --- |
| `EU` | Ireland |
| `US` | Virginia |

Your key has to belong to a tenant in the region you pick. Any other value is refused before the
request leaves Postman, naming the regions that are supported.

## Sending a request

Start with **List deployments**. On success it writes the first deployment's id into the collection
variable `deploymentId`, which **Get deployment**, **List deployment gateways** and **Get deployment
metrics** all use as their default - so they work straight away without copying an id by hand. After
that first run `deploymentId` appears in the **Variables** tab, where you can point it at a different
deployment.

Each request documents itself. Select one and open the documentation pane on the right for the roles
it needs, the fields it accepts, and what each response status means.

## Creating a deployment

The creation requests live in provider subfolders, because the request body genuinely differs per
cloud. Each ships a filled-in example body - replace the placeholder values with yours before
sending, in particular:

- `sicPassword` (`sicKey` on GCP) - the SIC key. You choose the value here and enter the same one on
  your management server, which is how the new gateways establish trust with it. It is used once at
  creation and never stored, so there is deliberately nowhere in the collection to keep it.
- The account, subscription or project identifiers under `vendorSettings`.

### Handling the SIC key

Type it into the request body just before you send, then two things in this order:

1. **Do not click Save** on the request. Saving writes the key into the collection itself, and it
   then travels with every export and share.
2. **Close the request tab** once the deployment is created. An unsaved body lives only in the open
   tab, so closing it is what actually clears the key.

A `201` means the deployment record exists and provisioning has started. It does not mean the
firewall is up - poll **Get deployment** to watch it progress.

## Troubleshooting

| Symptom | Cause | What to do |
| --- | --- | --- |
| `No API key configured` | The Vault entries are missing, or the collection was not granted Vault access. | Check `cfwaas-client-id` and `cfwaas-access-key` exist in the Vault, then re-send and allow access when asked. |
| `401` on every request | The key belongs to a different region than `region` is set to, or it was revoked. | Match `region` to the region the key was created in, or create a new key there. |
| `403` on a create | The key's role is Read Only. | Create a deployment with an **Admin** key. |
| `404` on a get | `deploymentId` is stale or belongs to another tenant. | Re-send **List deployments** to refresh it. |
| `Region "X" is not supported` | `region` names a region the service does not run in, or the case is wrong. | Set `region` to one of the codes under [Choosing your region](#choosing-your-region); they are case-sensitive. |

## Documentation

- [Cloud Firewall as a Service](https://www.checkpoint.com/cloudguard/cloud-network-security/)
- [Check Point Portal API keys](https://support.checkpoint.com/results/sk/sk180854)

---

Generated from the CFWaaS API Postman collection v1.5.5. Please do not edit this file by hand -
report issues through Check Point Support.
