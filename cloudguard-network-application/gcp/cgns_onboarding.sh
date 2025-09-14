#!/bin/bash
#set -x

PROJECT_SCOPE="project"
FOLDER_SCOPE="folder"

# Roles
OWNER_ROLE="roles/owner"
IAM_SECURITY_ADMIN="roles/iam.securityAdmin"
IAM_ORG_ROLE_ADMIN="roles/iam.organizationRoleAdmin"
CLOUD_GUARD_NSI_ROLE_NAME="Custom_Cloud_Guard_NSI_Role"
CLOUD_GUARD_ORGANIZATION_NSI_ROLE_NAME="Custom_Cloud_Guard_Organization_NSI_Role"


ROLES_LIST=(
  "$CLOUD_GUARD_NSI_ROLE_NAME"
  "$CLOUD_GUARD_ORGANIZATION_NSI_ROLE_NAME"
)

GCP_NSI_PRMISSIONS=(
  "compute.autoscalers.create"
  "compute.autoscalers.delete"
  "compute.autoscalers.get"
  "compute.autoscalers.update"
  "compute.disks.create"
  "compute.firewallPolicies.create"
  "compute.firewallPolicies.delete"
  "compute.firewallPolicies.get"
  "compute.firewallPolicies.update"
  "compute.firewallPolicies.use"
  "compute.firewalls.create"
  "compute.firewalls.delete"
  "compute.firewalls.get"
  "compute.firewalls.update"
  "compute.forwardingRules.create"
  "compute.forwardingRules.delete"
  "compute.forwardingRules.get"
  "compute.forwardingRules.use"
  "compute.globalOperations.get"
  "compute.healthChecks.create"
  "compute.healthChecks.delete"
  "compute.healthChecks.get"
  "compute.healthChecks.useReadOnly"
  "compute.instanceGroupManagers.create"
  "compute.instanceGroupManagers.delete"
  "compute.instanceGroupManagers.get"
  "compute.instanceGroupManagers.use"
  "compute.instanceGroups.delete"
  "compute.instanceGroups.use"
  "compute.instanceTemplates.create"
  "compute.instanceTemplates.delete"
  "compute.instanceTemplates.get"
  "compute.instanceTemplates.useReadOnly"
  "compute.instances.create"
  "compute.instances.setMetadata"
  "compute.instances.setTags"
  "compute.networks.create"
  "compute.networks.delete"
  "compute.networks.get"
  "compute.networks.setFirewallPolicy"
  "compute.networks.updatePolicy"
  "compute.networks.use"
  "compute.regionBackendServices.create"
  "compute.regionBackendServices.delete"
  "compute.regionBackendServices.get"
  "compute.regionBackendServices.use"
  "compute.regions.list"
  "compute.subnetworks.create"
  "compute.subnetworks.delete"
  "compute.subnetworks.get"
  "compute.subnetworks.use"
  "compute.subnetworks.useExternalIp"
  "compute.zones.list"
  "iam.serviceAccounts.actAs"
  "networksecurity.interceptDeploymentGroups.create"
  "networksecurity.interceptDeploymentGroups.delete"
  "networksecurity.interceptDeploymentGroups.get"
  "networksecurity.interceptDeploymentGroups.use"
  "networksecurity.interceptDeployments.create"
  "networksecurity.interceptDeployments.delete"
  "networksecurity.interceptDeployments.get"
  "networksecurity.interceptEndpointGroupAssociations.create"
  "networksecurity.interceptEndpointGroupAssociations.delete"
  "networksecurity.interceptEndpointGroupAssociations.get"
  "networksecurity.interceptEndpointGroups.create"
  "networksecurity.interceptEndpointGroups.delete"
  "networksecurity.interceptEndpointGroups.get"
  "networksecurity.interceptEndpointGroups.use"
  "networksecurity.securityProfiles.create"
  "resourcemanager.projects.get"
)

GCP_NSI_PRMISSIONS_ORGANIZATION=(
  "networksecurity.operations.get"
  "networksecurity.securityProfileGroups.create"
  "networksecurity.securityProfileGroups.delete"
  "networksecurity.securityProfileGroups.get"
  "networksecurity.securityProfileGroups.list"
  "networksecurity.securityProfileGroups.update"
  "networksecurity.securityProfileGroups.use"
  "networksecurity.securityProfiles.create"
  "networksecurity.securityProfiles.delete"
  "networksecurity.securityProfiles.get"
  "networksecurity.securityProfiles.list"
  "networksecurity.securityProfiles.update"
  "networksecurity.securityProfiles.use"
)


GCP_API_SERVICES=(
  "iam.googleapis.com"
  "serviceusage.googleapis.com"
  "cloudresourcemanager.googleapis.com"
)

# Function to join all API services into a single comma-separated string join_list_comma_separated "${GCP_NSI_PRMISSIONS[@]}"
join_list_comma_separated() {
  local arr=("$@")
  local IFS=","
  echo "${arr[*]}"
}


#Message Colors
end="\033[0m"
red="\033[0;31m"
function red {
  echo -e "${red}$*${end}"
}

yellowb="\033[1;33m"
function yellowb {
  echo -e "${yellowb}$*${end}"
}

yellow="\033[0;33m"
function yellow {
  echo -e "${yellow}$*${end}"
}

green="\033[0;32m"
function green {
  echo -e "${green}$*${end}"
}

lightblue="\033[0;36m"
function lightblue {
  echo -e "${lightblue}$*${end}"
}

gcloud_wrapper() {
  if [ "$dry_run" = "true" ]; then
    echo "gcloud $*"
    return 0
  fi

  # do not exit on error, capture it and forward to stdout to be handled by caller
  set +e
  GcloudOutput=$(gcloud "$@" --quiet --verbosity=error 2>&1)
  GcloudRetVal=$?
  set -e

}

enable_api_services() {
  for service in "${GCP_API_SERVICES[@]}"; do
    green "Enabling service $service"
    gcloud_wrapper services enable "$service" --project "$service_account_project_id"
    if [ $GcloudRetVal -ne 0 ]; then
      yellow "\nWarning: Failed to enable service $service. Error from Gcloud: \n$GcloudOutput. Continuing..."
    fi
  done
}

exit_with_error() {
  red "\n --------- Error --------"
  red "$1"
  red ""
  if [ "$dry_run" != "true" ]; then
    exit 1
  fi
}

exit_without_error() {
  green "$1"
  exit 0
}

check_if_user_would_like_to_proceed() {
  local message="$1"
  if [ "$quiet" = "true" ]; then
      return 0
  fi

  while true; do
    read -r -p "Would you like to proceed? (y/n): " choice

    case "$choice" in
      [Yy])
        green "Proceeding\n"
        break
        ;;
      [Nn])
        if [ -n "$message" ]; then
          yellow "$message"
        fi
        exit_without_error "Exiting"
        ;;
      *)
        red "Invalid choice. Please enter 'y' or 'n'."
        ;;
    esac
  done
}

default_inputs() {
  scope="project" #Set default scope to project
  dry_run="false" #Set default dry-run mode to false
  clean="false"
  quiet="false"
  project_id=""
  organization_id=""
  service_account_project_id=""
  enable_services="false" #Set default enable services to false
  create_key="false"
}


usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --service_account_project_id <project_id>       Project ID where the service account will be created"
  echo "  --service_account_name <name>                   Name of the service account"
  echo "  --project_id <project_id>                       Project ID where the service account will be used"
  echo "  --create_key                                    Create a key for the service account"
  echo "  --enable_services                               Enable GCP services"
  echo "  --clean                                         Clean up resources"
  echo "  --quiet                                         Quiet mode"
  echo "  --dry_run                                       Dry run mode"
  echo "  --help                                          Display this help message"
  echo ""
  echo "Example:"
  echo "  $0  --service_account_project_id my-project --service_account_name my-service-account --project_id my-project-id --enable_services --create_key"
  echo ""
}

parse_input() {

  default_inputs  

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --service_account_project_id)
      service_account_project_id="$2"
      if [ -z "$2" ]; then
        exit_with_error "Missing required service_account_project_id argument"
      fi
      shift 2
      ;;
    --service_account_name)
      service_account_name=$(echo "$2" | tr '[:upper:]' '[:lower:]')
      if [ -z "$2" ]; then
        exit_with_error "Missing required service_account_name argument"
      fi
      shift 2
      ;;
    --project_id)
      project_id="$2"
      if [ -z "$2" ]; then
        exit_with_error "Missing required project_id argument"
      fi
      shift 2
      ;;
    --folder_id)
      folder_id="$2"
      if [ -z "$2" ]; then
        exit_with_error "Missing required folder_id argument"
      fi
      shift 2
      ;;  
    --enable_services)
      enable_services="true"
      shift 1
      ;;
    --create_key)
      create_key="true"
      shift 1
      ;;
    --clean)
      clean="true"
      shift 1
      ;;
    --quiet)
      quiet="true"
      shift 1
      ;;
    --dry_run)
      dry_run="true"
      shift 1
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      yellow "Invalid option: $1"
      exit 1
      ;;
    esac
  done
}

validate_inputs() {
  if  [ -z "$project_id" ] || [ -z "$scope" ] || [ -z "$service_account_name" ]; then
    exit_with_error "Missing required arguments"
  fi

  if [ "$scope" != "$PROJECT_SCOPE" ]; then
    exit_with_error "Invalid scope argument. Can be '$PROJECT_SCOPE' given '$scope'"
  fi
}

set_scope() {
  if [ "$scope" = "$PROJECT_SCOPE" ]; then
    scopeVar="$PROJECT_SCOPE"
    scopeIdVar="$project_id"
  else
    exit_with_error "Invalid scope argument. Can be '$PROJECT_SCOPE', given '$scope'"
  fi
}


get_scope_iam_policy() {
  # Get the IAM policy for the specified scope
  if [ "$scopeVar" == "$PROJECT_SCOPE" ]; then
    gcloud_wrapper projects get-iam-policy "$scopeIdVar" --format=json
  fi

  if [ $GcloudRetVal -ne 0 ]; then
    exit_with_error "Failed to get IAM policy for $scopeVar $scopeIdVar. Error from Gcloud: \n$GcloudOutput"
  fi
}

get_organization_scope_iam_policy() {
  # Get the IAM policy for the specified scope
  gcloud_wrapper organizations get-iam-policy "$organization_id" --format=json
  if [ $GcloudRetVal -ne 0 ]; then
    exit_with_error "Failed to get IAM policy for $scopeVar $scopeIdVar. Error from Gcloud: \n$GcloudOutput"
  fi
}


# -----------------------------------------------------------------------------
# Function: create_project_custom_role_for_nsi
#
# Description:
#   Creates a custom IAM role in a specified GCP project for NSI onboarding.
#   The function first checks if the custom role already exists. If it does,
#   it skips creation. Otherwise, it creates the role with the specified
#   permissions and provides appropriate success or error messages.
#
# Globals:
#   CLOUD_GUARD_NSI_ROLE_NAME   - Name of the custom role to create.
#   GCP_NSI_PRMISSIONS          - Array of permissions to assign to the role.
#   project_id                  - GCP project ID where the role will be created.
#   GcloudRetVal                - Return value from the last gcloud_wrapper call.
#   GcloudOutput                - Output from the last gcloud_wrapper call.
#
# Arguments:
#   None
#
# Returns:
#   0 if the role already exists or is created successfully.
#   Exits with error if role creation fails.
#
# -----------------------------------------------------------------------------
create_project_custom_role_for_nsi() {
  local role_name=$CLOUD_GUARD_NSI_ROLE_NAME    
  local permissions
  permissions="$(join_list_comma_separated "${GCP_NSI_PRMISSIONS[@]}")"
  # Check if the role already exists
  gcloud_wrapper iam roles describe "$role_name" --project="$project_id" --format=json
  # Check if the role exists and is not deleted
  if [ $GcloudRetVal -eq 0 ]; then
    local is_deleted
    is_deleted=$(echo "$GcloudOutput" | jq -r '.deleted // false')
    if [ "$is_deleted" = "true" ]; then
      # Role exists but is in deleted state, so we should create it again
      GcloudRetVal=1
      yellow "Custom role $role_name exists but is in deleted state. Will undelete it."
    fi
  fi
  if [ $GcloudRetVal -eq 0 ]; then
    yellow "Custom role $role_name already exists in project $project_id. Skipping creation."
    return 0
  fi
  if [ "$is_deleted" = "true" ]; then
    # Undelete the role if it was previously deleted
    gcloud_wrapper iam roles undelete "$role_name" --project="$project_id"
    if [ $GcloudRetVal -ne 0 ]; then
      exit_with_error "Failed to undelete custom role $role_name. Error from Gcloud: \n$GcloudOutput"
    fi
    green "\nUndeleting custom role $role_name"
    return 0
  fi
  # Create a custom role with the specified permissions
  gcloud_wrapper iam roles create "$role_name" --project="$project_id" --title="$role_name" --permissions="$permissions" --description="Custom role for NSI onboarding"
  if [ $GcloudRetVal -ne 0 ]; then
    exit_with_error "Failed to create custom role $role_name. Error from Gcloud: \n$GcloudOutput"
  fi
  green "\nCreating custom role $role_name with permissions: $permissions"
}


create_organization_custom_role_for_nsi() {
  local role_name=$CLOUD_GUARD_ORGANIZATION_NSI_ROLE_NAME     
  local permissions
  permissions="$(join_list_comma_separated "${GCP_NSI_PRMISSIONS_ORGANIZATION[@]}")"
  # Check if the role already exists
  gcloud_wrapper iam roles describe "$role_name" --organization="$organization_id" --format=json
  # Check if the role exists and is not deleted
  if [ $GcloudRetVal -eq 0 ]; then
    local is_deleted
    is_deleted=$(echo "$GcloudOutput" | jq -r '.deleted // false')
    if [ "$is_deleted" = "true" ]; then
      # Role exists but is in deleted state, so we should create it again
      GcloudRetVal=1
      yellow "Custom role $role_name exists but is in deleted state. Will undelete it."
    fi
  fi
  if [ $GcloudRetVal -eq 0 ]; then
    yellow "Custom role $role_name already exists in organization $organization_id. Skipping creation."
    return 0
  fi
  if [ "$is_deleted" = "true" ]; then
    # Undelete the role if it was previously deleted
    gcloud_wrapper iam roles undelete "$role_name" --organization="$organization_id"
    if [ $GcloudRetVal -ne 0 ]; then
      exit_with_error "Failed to undelete custom role $role_name. Error from Gcloud: \n$GcloudOutput"
    fi
    green "\nUndeleting custom role $role_name"
    return 0
  fi
  # Create a custom role with the specified permissions
  gcloud_wrapper iam roles create "$role_name" --organization="$organization_id" --title="$role_name" --permissions="$permissions" --description="Custom role for NSI onboarding"
  if [ $GcloudRetVal -ne 0 ]; then
    exit_with_error "Failed to create custom role $role_name. Error from Gcloud: \n$GcloudOutput"
  fi
  green "\nCreating custom role $role_name with permissions: $permissions"
}


#################################################################
# Function: get_project_organization_id
# Description: Retrieves the organization ID associated with the specified project.
#              The function uses the Google Cloud SDK to query the project's ancestors
#              and extracts the organization ID from the response.
#
# Parameters:
#   None directly, but uses the global variable:
#   - project_id: The Google Cloud project ID to query
#
# Globals Used:
#   - project_id: Input project ID
#   - GcloudRetVal: Return value from gcloud_wrapper function
#   - GcloudOutput: Output from gcloud_wrapper function
#   - organization_id: Variable to store the retrieved organization ID
#
# Returns:
#   Sets the global variable organization_id with the retrieved organization ID
#
# Exit Codes:
#   Calls exit_with_error if unable to retrieve organization ID
##################################################################
get_project_organization_id() {
  if [ -n "$project_id" ]; then
    gcloud_wrapper projects get-ancestors "$project_id" --format json
    if [ $GcloudRetVal -ne 0 ]; then
      exit_with_error "Failed to get organization ID for project $project_id. Error from Gcloud: \n$GcloudOutput"
    fi
    organization_id=$(echo "$GcloudOutput" | jq -r '.[] | select(.type == "organization") | .id')
    green "\nOrganization ID is: $organization_id\n"
  fi
}

################################################################
# Function: is_role_unassigned
# Description: Checks if a specific IAM role is not assigned to a service account.
# 
# Arguments:
#   $1 - role: The GCP IAM role to check (e.g., "roles/compute.viewer")
#   $2 - iam_policy: JSON string containing the IAM policy for the scope
#
# Global variables used:
#   service_account_email: Email of the service account to check
#
# Returns:
#   0 - If the role is NOT assigned to the service account
#   1 - If the role IS assigned to the service account
#
# Output:
#   Prints colored message indicating whether the role is assigned or not
#############################################################
is_role_unassigned() {
    local role="$1"             # Role to check
    local iam_policy="$2"        # IAM policy for the scope

    # Check if the role is assigned to the service account
    local role_assigned
    role_assigned=$(echo "$iam_policy" | jq -r ".bindings[] | select(.role == \"$role\") | .members[] | select(. == \"serviceAccount:$service_account_email\")")
    if [[ -n $role_assigned ]]; then
      green "\nRole $role is assigned to the service account $service_account_email"
      return 1  # Role assigned
    else
      green "\nRole $role is not assigned to the service account $service_account_email"
      return 0  # Role not assigned
    fi
}


add_role_assignment_if_needed() {
  local role="$1"
  local iam_policy="$2"

  if is_role_unassigned "$role" "$iam_policy"; then
    green "Assigning role $role to service account $service_account_email for $scopeVar $scopeIdVar"
    if [ "$scopeVar" == "$PROJECT_SCOPE" ]; then
        gcloud_wrapper projects add-iam-policy-binding "$scopeIdVar" --member "serviceAccount:$service_account_email" --role "$role" --condition=None
    fi
    if [ $GcloudRetVal -ne 0 ]; then
      exit_with_error "Failed to assign role $role to service account $service_account_email for $scopeVar: $scopeIdVar. Error from Gcloud: \n$GcloudOutput"
    fi
  fi
}


#for deploying nsi we need to add the role on the organization level
add_role_assignment_organization_if_needed() {
  local role="$1"
  local iam_policy="$2"

  if is_role_unassigned "$role" "$iam_policy"; then
    green "Assigning role $role to service account $service_account_email for organization/$organization_id scope"
    gcloud_wrapper organizations add-iam-policy-binding "organizations/$organization_id" --member "serviceAccount:$service_account_email" --role "$role" --condition=None

    if [ $GcloudRetVal -ne 0 ]; then
      exit_with_error "Failed to assign role $role to service account $service_account_email for $scopeVar: $scopeIdVar. Error from Gcloud: \n$GcloudOutput"
    fi
  fi
}

add_role_assignments_CGNS() {
  local scope_iam_policy="$1"
  local CLOUD_GUARD_PROJECT_NSI_ROLE="projects/$project_id/roles/$CLOUD_GUARD_NSI_ROLE_NAME"
  local CLOUD_GUARD_ROLES_LIST=(
    "$CLOUD_GUARD_PROJECT_NSI_ROLE"
  )
  for role in "${CLOUD_GUARD_ROLES_LIST[@]}"; do
    add_role_assignment_if_needed "$role" "$scope_iam_policy"
  done
}



add_role_assignments_organization_CGNS() {
  local scope_iam_policy="$1"
  local CLOUD_GUARD_ORGANIZATION_NSI_ROLE="organizations/$organization_id/roles/$CLOUD_GUARD_ORGANIZATION_NSI_ROLE_NAME"
  # You can add more organization-level custom roles here if needed
  local CLOUD_GUARD_ROLES_LIST=(
    "$CLOUD_GUARD_ORGANIZATION_NSI_ROLE"
    # Add more roles if required
  )
  for role in "${CLOUD_GUARD_ROLES_LIST[@]}"; do
    add_role_assignment_organization_if_needed "$role" "$scope_iam_policy"
  done
}


add_role_assignments() {
  get_scope_iam_policy
  local scope_iam_policy="$GcloudOutput"

  green "\nAssigning project-level roles to service account..."
  add_role_assignments_CGNS "$scope_iam_policy"

  get_organization_scope_iam_policy
  local organization_iam_policy="$GcloudOutput"
  
  green "\nAssigning organization-level roles to service account..."
  add_role_assignments_organization_CGNS "$organization_iam_policy"
}



set_service_account_email() {
  service_account_email=$(echo "$service_account_name@$service_account_project_id.iam.gserviceaccount.com" | tr '[:upper:]' '[:lower:]')
}


################################################################
# Creates a service account in GCP if it doesn't already exist
#
# This function checks if a service account with the specified name exists in the given project.
# If it doesn't exist, it creates the service account. If it already exists, it notifies the user
# and prompts them to proceed or rename the service account.
#
# Variables used:
# - service_account_project_id: The GCP project ID where the service account should be created
# - service_account_email: The email address of the service account to check
# - service_account_name: The name of the service account to create if needed
#
# Returns:
# - Nothing on success
# - Exits with error if unable to list or create service accounts
###############################################################
create_service_account_if_required() {
    gcloud_wrapper iam service-accounts list --project="$service_account_project_id" --filter="email:$service_account_email" --format="value(email)"
    if [ $GcloudRetVal -ne 0 ]; then
        exit_with_error "Failed to list service accounts for project $service_account_project_id. Error from Gcloud: \n$GcloudOutput"
    fi
    if [ -z "$GcloudOutput" ]; then
        green "Service account $service_account_name does not exists, Creating service account $service_account_name"
        gcloud_wrapper iam service-accounts create "$service_account_name" --project "$service_account_project_id"
        if [ $GcloudRetVal -ne 0 ]; then
        exit_with_error "Failed to create service account $service_account_name service_account_project_id $service_account_project_id. Error from Gcloud: \n$GcloudOutput"
        fi
    else
        yellow "\nService account $service_account_name already exists. We will proceed with the existing service account."
        check_if_user_would_like_to_proceed "Please rename the 'service_account_name' parameter to a different name."
    fi
}


##############################################################
# Check if a role exists in IAM policy bindings
# 
# This function checks if a specific role is present in the provided IAM policy bindings JSON.
# 
# Args:
#   role: The role name to check for (e.g., "roles/editor")
#   bindings: JSON string containing IAM policy bindings
# 
# Returns:
#   0: If the role does NOT exist in the bindings
#   1: If the role exists in the bindings
#
# Example:
#   bindings=$(gcloud projects get-iam-policy PROJECT_ID --format=json | jq '.bindings')
#   if role_exists_in_bindings "roles/editor" "$bindings"; then
#     echo "Role does not exist"
#   else
#     echo "Role exists"
#   fi
#############################################################
role_exists_in_bindings() {
  local role="$1"
  local bindings="$2"

  count=$(echo "$bindings" | jq -r "[.[] | select(.role == \"$role\")] | length")
  if [ "$count" -gt 0 ]; then
    return 1
  fi
  return 0
}

#####################################################
## validate_project_user_permissions
# 
# Validates whether a user has owner permissions on a GCP project.
# The function checks the IAM policy of the project and its ancestors to determine
# if the specified user has the owner role.
#
# Args:
#   $1 (user_email): The email address of the user to check
#   $2 (project_id): The GCP project ID to validate permissions on
#
# Returns:
#   None
#
# Exits:
#   1: If unable to retrieve IAM policy information or if the user lacks owner permissions
#
# Dependencies:
#   - gcloud_wrapper: Function to execute gcloud commands
#   - role_exists_in_bindings: Function to check if a role exists in IAM bindings
#   - exit_with_error: Function to exit with an error message
#   - green: Function to output success messages
#
# Global variables used:
#   - GcloudRetVal: Return value of the last gcloud command
#   - GcloudOutput: Output of the last gcloud command
#   - OWNER_ROLE: Role to check for (presumably "roles/owner")
#####################################################
validate_project_user_permissions() {
  local user_email="$1"
  local project_id="$2"
  gcloud_wrapper projects get-ancestors-iam-policy "$project_id" --format=json
  if [ $GcloudRetVal -ne 0 ]; then
    gcloud_wrapper projects get-iam-policy "$project_id" --format=json
  fi
  if [ $GcloudRetVal -ne 0 ]; then
    exit_with_error "Failure on get-ancestors-iam-policy project $project_id. Error from Gcloud: \n$GcloudOutput"
  fi  
  local bindings
  bindings=$(echo "$GcloudOutput" | jq -r 'if type == "array" then . else [.] end | [.[] | if .bindings then .bindings else .policy.bindings end | .[] | select(.members[] | contains("user:'"$user_email"'"))]')
  if [ $GcloudRetVal -ne 0 ]; then
    exit_with_error "Failure on get-ancestors-iam-policy project $project_id. Error from Gcloud: \n$GcloudOutput"
  fi
  if ! role_exists_in_bindings "$OWNER_ROLE" "$bindings"; then
    green "User $user_email has $OWNER_ROLE role on project $project_id"
  else
    yellow "User $user_email does not have $OWNER_ROLE role on project $project_id in order to perform the onboarding actions\nyou must have equivalent permissions that allow you to:
    \n- Create and manage service accounts \n- Create custom IAM roles at both
    organization and project levels \n- Assign roles to the service account."
    check_if_user_would_like_to_proceed
  fi
}


validate_project_user_permissions_by_projectId(){
  local user_email="$1"
  validate_project_user_permissions "$user_email" "$project_id"
  if [ "$project_id" != "$service_account_project_id" ]; then
    validate_project_user_permissions "$user_email" "$service_account_project_id"
  fi
}



validate_folder_user_permissions() {
  local user_email="$1"
  gcloud_wrapper resource-manager folders get-ancestors-iam-policy "$folder_id" --flatten='policy.bindings[].members' --format=json --filter=policy.bindings.members="user:$user_email"
  if [ $GcloudRetVal -ne 0 ]; then
    exit_with_error "Failure on resource-manager folders get-ancestors-iam-policy $folder_id. Error from Gcloud: \n$GcloudOutput"
  fi
  local bindings
  bindings=$(echo "$GcloudOutput" | jq -r "[.[] | .policy.bindings]")
  if ! role_exists_in_bindings "$OWNER_ROLE" "$bindings"; then
    green "User $user_email has $OWNER_ROLE role on folder $folder_id"
  else
    exit_with_error "User $user_email does not have $OWNER_ROLE role on folder $folder_id"
  fi
}

validate_organization_user_permissions() {
  local user_email="$1"
  gcloud_wrapper organizations get-iam-policy "$organization_id" --flatten='bindings[].members' --format=json --filter=bindings.members="user:$user_email"
  if [ $GcloudRetVal -ne 0 ]; then
    exit_with_error "Failure on get-iam-policy organization $organization_id. Error from Gcloud: \n$GcloudOutput"
  fi
  local bindings
  bindings=$(echo "$GcloudOutput" | jq -r "[.[] | .bindings]")
  if ! role_exists_in_bindings "$OWNER_ROLE" "$bindings"; then
    green "User $user_email has the $OWNER_ROLE role on organization $organization_id"
  elif ! role_exists_in_bindings "$IAM_SECURITY_ADMIN" "$bindings" && ! role_exists_in_bindings "$IAM_ORG_ROLE_ADMIN" "$bindings"; then
    green "User $user_email has the $IAM_SECURITY_ADMIN and the $IAM_ORG_ROLE_ADMIN roles on organization $organization_id"
  else
    yellow "User $user_email does not have the required $IAM_ORG_ROLE_ADMIN or $IAM_SECURITY_ADMIN role on organization $organization_id in order to perform the onboarding actions\nyou must have equivalent permissions that allow you to:
    \n- Create and manage service accounts \n- Create custom IAM roles at both
    organization and project levels \n- Assign roles to the service account."
    check_if_user_would_like_to_proceed
  fi
}

validate_user_permissions() {
  gcloud_wrapper config get-value account
  if [ $GcloudRetVal -ne 0 ]; then
    exit_with_error "Failure on getting currently active google cloud account that the gcloud CLI is using for authentication and API calls. Error from Gcloud: \n$GcloudOutput"
  fi
  local user_email
  user_email=$(echo "$GcloudOutput" | tail -1)

  if [ "$scopeVar" = "$PROJECT_SCOPE" ]; then
    validate_project_user_permissions_by_projectId "$user_email"
  elif [ "$scopeVar" = "$FOLDER_SCOPE" ]; then
    validate_folder_user_permissions "$user_email"
  fi
  # need to check organization permission for nsi
  validate_organization_user_permissions "$user_email"
}


list_output() {
  local inputList=("$@")
  local message=""
    for item in "${inputList[@]}"; do
        message+=" $item\n"
    done
    echo "$message"
}


##########################################################################
# Function Name: user_information
# Description: Displays information about the actions the script will perform and asks for user confirmation to proceed.
# 
# This function informs the user about:
# - Services to be enabled (if applicable)
# - Service account creation details
# - Roles to be assigned
# - Whether a service account key will be created
#
# After displaying the information, it prompts the user to confirm before proceeding.
#
# Arguments:
#   None - Uses global variables for configuration
#
# Global Variables Used:
#   create_key - Boolean flag for service account key creation
#   scopeVar - Scope type (project, folder, or organization)
#   scopeIdVar - ID of the scope
#   enable_services - Boolean flag for enabling GCP services
#   GCP_API_SERVICES - Array of GCP services to enable
#   service_account_name - Name of the service account
#   service_account_project_id - Project ID for the service account
#   ROLES_LIST - Array of roles to be assigned
#
# Returns:
#   None - Proceeds if user confirms, likely exits if user declines
##########################################################################
user_information() {
  local roles_list
  roles_list=$(list_output "${ROLES_LIST[@]}")

  lightblue "The script will execute the following steps:\n"

  if [ "$enable_services" = "true" ]; then
    message="- Enable the following GCP services:\n"
    local serviceList
    serviceList=$(list_output "${GCP_API_SERVICES[@]}")
    message+="$serviceList"
    lightblue "$message"
  fi
  lightblue "- Create custom roles if they do not exist."
  lightblue "- Create a service account '$service_account_name' in project '$service_account_project_id' if it does not exist.\n"
  lightblue "- Assign the following roles to the service account:\n$roles_list\n"

  if [ "$create_key" = "true" ]; then
    lightblue "- Create a key for the service account.\n"
  fi

  check_if_user_would_like_to_proceed
}

# Remove role assignment if it exists
remove_role_assignment_if_needed() {
  local role="$1"
  local iam_policy="$2"

  if ! is_role_unassigned "$role" "$iam_policy"; then
    green "Removing $role role assignment from service account $service_account_email"
    if [ "$scopeVar" == "$PROJECT_SCOPE" ]; then
        gcloud_wrapper projects remove-iam-policy-binding "$scopeIdVar" --member "serviceAccount:$service_account_email" --role "$role"
    elif [ "$scopeVar" == "$FOLDER_SCOPE" ]; then
        gcloud_wrapper resource-manager folders remove-iam-policy-binding "$scopeIdVar" --member "serviceAccount:$service_account_email" --role "$role"
    else # organization scope
        gcloud_wrapper organizations remove-iam-policy-binding "$scopeIdVar" --member "serviceAccount:$service_account_email" --role "$role"
    fi
    if [ $GcloudRetVal -ne 0 ]; then
      exit_with_error "Failed to remove role $role from service account $service_account_email for $scopeVar: $scopeIdVar. Error from Gcloud: \n$GcloudOutput"
    fi
  fi
}

remove_organization_role_assignment_if_needed() {
  local role="$1"
  local iam_policy="$2"

  if ! is_role_unassigned "$role" "$iam_policy"; then
    green "Removing $role role assignment from service account $service_account_email"
    gcloud_wrapper organizations remove-iam-policy-binding "$organization_id" --member "serviceAccount:$service_account_email" --role "$role"
    if [ $GcloudRetVal -ne 0 ]; then
      exit_with_error "Failed to remove role $role from service account $service_account_email for organization: $organization_id. Error from Gcloud: \n$GcloudOutput"
    fi
  fi
} 


# Function to delete a custom role from a specified scope
delete_custom_role() {
  local role_name="$1"
  local scope_type="$2"  # "project" or "organization"
  local scope_id="$3"
  local scope_flag=""
  
  if [ "$scope_type" = "project" ]; then
    scope_flag="--project"
  elif [ "$scope_type" = "organization" ]; then
    scope_flag="--organization"
  else
    yellow "Invalid scope type: $scope_type. Must be 'project' or 'organization'."
    return 1
  fi
  
  gcloud_wrapper iam roles describe "$role_name" "$scope_flag"="$scope_id" --format=json
  if [ $GcloudRetVal -eq 0 ]; then
    # Check if the role is already in a deleted state
    local is_deleted
    is_deleted=$(echo "$GcloudOutput" | jq -r '.deleted // false')
    
    if [ "$is_deleted" = "true" ]; then
      yellow "Custom role $role_name in $scope_type $scope_id is already in deleted state. No action needed."
    else
      green "\nDeleting $scope_type-level custom role: $role_name"
      gcloud_wrapper iam roles delete "$role_name" "$scope_flag"="$scope_id"
      if [ $GcloudRetVal -ne 0 ]; then
        yellow "Warning: Failed to delete custom role $role_name from $scope_type $scope_id. Error from Gcloud: \n$GcloudOutput"
      else
        green "Successfully deleted $scope_type-level custom role: $role_name"
      fi
    fi
  else
    yellow "Custom role $role_name does not exist in $scope_type $scope_id or cannot be accessed."
  fi
}


delete_custom_roles() {
  green "\nChecking for and deleting custom roles..."
  
  # Delete project-level custom role
  delete_custom_role "$CLOUD_GUARD_NSI_ROLE_NAME" "project" "$project_id"

  # Delete organization-level custom role
  if [ -n "$organization_id" ]; then
    delete_custom_role "$CLOUD_GUARD_ORGANIZATION_NSI_ROLE_NAME" "organization" "$organization_id"
  else
    yellow "Organization ID not provided or not found. Skipping organization-level role deletion."
  fi
}


delete_service_account() {
  # Check if the service account exists before attempting to delete it
  gcloud_wrapper iam service-accounts list --project="$service_account_project_id" --filter="email:$service_account_email" --format="value(email)"
  if [ $GcloudRetVal -ne 0 ]; then
    exit_with_error "Failed to check if service account $service_account_email exists. Error from Gcloud: \n$GcloudOutput"
  fi
  
  # Only attempt deletion if the service account exists
  if [ -n "$GcloudOutput" ]; then
    green "\nDeleting service account $service_account_email"
    gcloud_wrapper iam service-accounts delete "$service_account_email" --project "$service_account_project_id"
    if [ $GcloudRetVal -ne 0 ]; then
      exit_with_error "Failed to delete service account $service_account_email. Error from Gcloud: \n$GcloudOutput"
    fi
    green "Service account $service_account_email deleted successfully"
  else
    yellow "Service account $service_account_email does not exist. No need to delete."
  fi
}

##############################################################
# Rollback Check Point CloudGuard Network Security Integration (CGNS) for GCP.
# This function performs the following clean-up operations:
# 1. Retrieves the current IAM policy for the project scope
# 2. Gets the organization ID associated with the project
# 3. Removes any role assignments for CloudGuard service accounts at the project level
# 4. Retrieves the IAM policy for the organization scope
# 5. Removes any role assignments for CloudGuard service accounts at the organization level
# 6. Deletes any custom roles created during the CGNS onboarding
# 7. Deletes the CloudGuard service account
#
# This function should be used to completely clean up all CGNS components when
# uninstalling the CloudGuard Network Security integration.
#########################################
rollback_CGNS() {
  get_scope_iam_policy
  local scope_iam_policy=$GcloudOutput
  get_project_organization_id
  local CLOUD_GUARD_PROJECT_NSI_ROLE="projects/$project_id/roles/$CLOUD_GUARD_NSI_ROLE_NAME"
  local CLOUD_GUARD_ORGANIZATION_NSI_ROLE="organizations/$organization_id/roles/$CLOUD_GUARD_ORGANIZATION_NSI_ROLE_NAME"
  local CLOUD_GUARD_ROLES_LIST=(
    "$CLOUD_GUARD_PROJECT_NSI_ROLE"
  )
  for role in "${CLOUD_GUARD_ROLES_LIST[@]}"; do
    remove_role_assignment_if_needed "$role" "$scope_iam_policy"
  done
  get_organization_scope_iam_policy
  local organization_scope_iam_policy=$GcloudOutput
  remove_organization_role_assignment_if_needed "$CLOUD_GUARD_ORGANIZATION_NSI_ROLE" "$organization_scope_iam_policy"
  delete_custom_roles
  delete_service_account
}

rollback() {
  if [ "$clean" = "true" ]; then
    lightblue "\nClean mode is enabled."
    lightblue "\nWe will delete all the resources created in the script."
    check_if_user_would_like_to_proceed

    lightblue "\nStarts cleaning process"
    rollback_CGNS
    exit_without_error " \n--------- Clean Completed Successfully --------"
  fi
}

create_service_account_key() {
  gcloud_wrapper iam service-accounts keys create "$service_account_name.json" --iam-account "$service_account_email" --project "$service_account_project_id"
  if [ $GcloudRetVal -ne 0 ]; then
    exit_with_error "Failure on iam service-accounts keys create $service_account_name.json for $service_account_email and project $service_account_project_id. Error from Gcloud: \n$GcloudOutput"
  fi

  lightblue "\nService account key created successfully\n\n"

  lightblue "\n---------- COPY THE JSON BELOW ----------\n"
  cat "$service_account_name.json"
  lightblue "\n---------- COPY THE JSON ABOVE ----------\n"

  rm "$service_account_name.json"
}

#########################
######### Main ##########
#########################

main() {
  parse_input "$@"
  validate_inputs
  set_scope
  set_service_account_email
  rollback
  user_information
  get_project_organization_id
  validate_user_permissions

 if [ "$enable_services" = "true" ]; then
  enable_api_services
 else
   green "Skip enable services"
 fi
 create_service_account_if_required
 create_project_custom_role_for_nsi
 create_organization_custom_role_for_nsi
 add_role_assignments
 if [ "$create_key" = "true" ]; then
   create_service_account_key
 fi


 green " \n--------- CloudGuard app registered Successfully --------\n"
 lightblue "\nPlease go back to the CloudGuard onboarding wizard to complete the onboarding process\n"

}

main "$@"
