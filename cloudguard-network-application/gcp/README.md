# cgns_onboarding_gcp.sh

This script automates onboarding of Google Cloud Platform (GCP) accounts for the CloudGuard Network Security (CGNS) SaaS application.

## Prerequisites

To connect your GCP account to CloudGuard Network Security, ensure you have the following permissions:

### Required GCP Organization Permissions
- `roles/iam.organizationRoleAdmin`
- `roles/iam.securityAdmin`

### Required GCP Project Permission
- `roles/owner` (Project Owner role)

Alternatively, you must have equivalent permissions that allow you to:
- Create and manage service accounts
- Create custom IAM roles at both organization and project levels
- Assign roles to service accounts
- Enable required APIs

These permissions are necessary for the script to properly configure the integration between CloudGuard and your GCP environment.

  
## Overview

This script supports onboarding at the project level, including:
- Creation of custom IAM roles with the required permissions for CGNS.
- Creation of a dedicated service account for CloudGuard.
- Assignment of custom roles to the service account at both project and organization levels.
- Enabling required GCP APIs.
- Optional creation of a service account private key.
- Optional cleanup (removal) of all created resources using the `--clean` flag.

### Main Actions
- **Custom Role Creation:** Creates project-level and organization-level custom roles with all permissions required by CGNS.
- **Service Account Creation:** Creates a dedicated service account in the specified project.
- **Role Assignment:** Assigns the custom roles and any required built-in roles to the service account at both project and organization scopes.
- **API Enablement:** Enables required GCP APIs (IAM, Service Usage, Cloud Resource Manager).
- **Resource Cleanup (optional, using `--clean` flag):** Removes all created roles, service accounts, and role assignments.

## Features

- Onboarding at the project level (organization-level roles are also handled if required).
- Automated creation and assignment of custom roles.
- Dry-run and quiet modes.
- Optional full cleanup of all resources created by the script.

## Usage

```sh
./cgns_onboarding_gcp.sh [OPTIONS]
```

### Options

- `--service_account_project_id <project_id>`: Project ID where the service account will be created.
- `--service_account_name <name>`: Name of the service account.
- `--project_id <project_id>`: Project ID where the service account will be used.
- `--create_key`: Create a key for the service account (optional).
- `--enable_services`: Enable required GCP APIs (optional).
- `--clean`: Clean up (delete) all resources created by the script (optional).
- `--quiet`: Suppress user interaction prompts (optional).
- `--dry_run`: Run in dry-run mode (no changes will be made).
- `--help`: Show usage information.

### Example

Onboard a project with a new service account and custom roles:

```sh
./cgns_onboarding_gcp.sh \
  --service_account_project_id my-gcp-project \
  --service_account_name cloudguard-sa \
  --project_id my-gcp-project \
  --enable_services \
  --create_key
```

Clean up all resources created by the script:

```sh
./cgns_onboarding_gcp.sh \
  --service_account_project_id my-gcp-project \
  --service_account_name cloudguard-sa \
  --project_id my-gcp-project \
  --clean
```

## Notes

- The script will prompt for confirmation unless `--quiet` is specified.
- Use `--dry_run` to preview actions without making changes.
- Output may include sensitive credentials; handle with care.
- Organization-level permissions are required for some operations (such as custom role creation/assignment at the organization scope).
