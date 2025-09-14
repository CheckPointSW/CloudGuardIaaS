# cgns_onboarding_azure.sh


This script automates onboarding of Azure accounts for the CloudGuard Network Security (CGNS) SaaS application.

## Prerequisites

- Sufficient Azure permissions (Owner permission over the selected subscription or management group for assigning ARM access role and Global Administrator role for creating new Azure application).

## Overview

This script supports onboarding at both the subscription or management group level supporting two modes:

- **Customer-managed (single-tenant):** You create and own a dedicated Azure application and service principal within your tenant. 
- **CloudGuard-managed (multi-tenant):** You use a pre-existing CloudGuard-managed Azure application. CloudGuard owns and manages the app registration, while you only assign its service principal to your Azure resources.


For customer-managed (single-tenant) onboarding, the script performs the following steps:
- **Azure Application Registration:** Creates a dedicated Azure application for the customer’s tenant.
- **Service Principal Creation:** Registers a service principal for the newly created application, enabling programmatic access to Azure resources.
- **Role Assignment:** Assigns the necessary Azure roles (such as `Reader` or `Contributor`) to the service principal at the subscription or management group level to ensure CGNS can operate as required.
- **Resource Cleanup (optional, using `--clean` flag):** Removes the application, service principal, and associated role assignments to fully clean up the integration if requested.  
  > **Note:** When using the `--clean` option, you must also provide the `--app_name`, `--scope`, and the relevant `--subscription_id` or `--management_group_id` to ensure proper identification and removal of resources. 

For CloudGuard-managed (multi-tenant) onboarding, the script performs the following steps:
- **Service Principal Assignment:** Assigns a service principal for the pre-existing CloudGuard-managed Azure application to the customer’s subscription or management group.
- **Role Assignment:** Ensures the service principal has the required permissions by assigning appropriate roles.
- **Resource Cleanup (optional, using `--clean` flag):** Removes the service principal assignment and revokes permissions when offboarding.

## Features

### Script Support

- Onboarding at both Subscription and Management Group scopes.
- Single-tenant (customer-managed) and multi-tenant (CloudGuard-managed) app registrations.
- Dry-run and quiet modes.

### Script Actions

- Assigns required Azure roles (`Reader`, `Contributor`, `User Access Administrator`).
- Validates user permissions before making changes.
- Optional clean up (delete) of created resources.

## Usage

```sh
./cgns_onboarding_azure.sh [OPTIONS]
```

### Options

- `--scope` **[required]**: Specifies the onboarding scope. Can be either `subscription` or `management-group`.
- `--subscription_id` **[required for subscription scope]**: Azure Subscription ID.
- `--management_group_id` **[required for management-group scope]**: Azure Management Group ID.
- `--onboarding_mode` **[required]**: Onboarding mode for CloudGuard_CGNS. Can be either `read-only`assigns 'Reader' role or `manage` assigns 'Contributor' and 'User Access Administrator'.
- `--multi_tenant_app_id` **[required for CloudGuard-managed (multi-tenant) mode]**: CloudGuard_CGNS Azure application ID (for CloudGuard-managed application).
- `--single_tenant_app_mode` **[required for customer-managed (single-tenant) mode]**: Use customer-managed Azure application registration.
- `--app_name` **[required with --single_tenant_app_mode]**: Name for the Azure AD application.
- `--dry_run` **[optional]**: Run in dry-run mode (no changes will be made).
- `--clean` **[optional]**: Delete all resources created by the script.
- `--quiet` **[optional]**: Suppress user interaction prompts.
- `--help`: Show usage information.

### Example

Onboard a subscription with a new customer-managed application:

```sh
./cgns_onboarding_azure.sh \
  --scope subscription \
  --subscription_id <SUBSCRIPTION_ID> \
  --onboarding_mode manage \
  --single_tenant_app_mode true \
  --app_name "CloudGuardApp"
```

Onboard using an existing multi-tenant application:

```sh
./cgns_onboarding_azure.sh \
  --scope management-group \
  --management_group_id <MG_ID> \
  --onboarding_mode read-only \
  --multi_tenant_app_id <APP_ID>
```

Clean up resources:

```sh
./cgns_onboarding_azure.sh --scope subscription --subscription_id <SUBSCRIPTION_ID> --onboarding_mode "read-only" --single_tenant_app_mode true --clean
```



## Notes

- The script will prompt for confirmation unless `--quiet` is specified.
- Use `--dry_run` to preview actions without making changes.
- Output includes sensitive credentials; handle with care.
