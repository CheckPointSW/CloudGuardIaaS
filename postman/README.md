# Postman Collections

API collections for Check Point CloudGuard Network Security, one directory per API.

Postman is an API client for creating, sharing, testing and documenting APIs. It imports and exports
collections, environments and variables as data files, which is what each directory here holds.

## Collections

| Directory | API | Collection |
| --- | --- | --- |
| [`cfwaas_api_postman`](cfwaas_api_postman/) | Cloud Firewall as a Service - managed firewall deployments on AWS, Azure and GCP | `cfwaas_api.postman_collection.json` |
| [`cme_api_postman`](cme_api_postman/) | Cloud Management Extension - gateway auto-provisioning | `CME_API.postman_collection` |
| [`vwan_postman`](vwan_postman/) | Azure Virtual WAN - virtual WANs, hubs and connections | `vwan.postman_collection.json` |

Each directory has its own README covering import, credentials and first use. Start there.

## Layout

```
postman/
└── <api>_postman/
    ├── <api>.postman_collection.json   the collection
    └── README.md                        how to import and use it
```

One directory per API, named `<api>_postman`. Anything a collection needs alongside it - an
environment file, a sample data file - belongs in the same directory.

## A note on the previous location

Collections used to live under `common/`, which is a general-purpose directory of scripts and
helpers. Those copies are still in place so existing regression jobs that reference the old paths
keep working, and their READMEs are marked deprecated.

**They are frozen.** A new version of a collection is published here and here only. If you are
adding a collection, add it here.
