#!/bin/bash


# Set the output format for Azure CLI to JSON
export AZURE_CORE_OUTPUT=json

#GLOBAL CONSTANTS
MANAGEMENT_GROUPS="providers/Microsoft.Management/managementGroups"
MANAGEMENT_GROUPS_SCOPE="management-group"
SUBSCRIPTIONS="subscriptions"
SUBSCRIPTION_SCOPE="subscription"
NECESSARY_PERMISSIONS_STR="Please make sure you have all the necessary permissions"
MANAGE="manage"
READ_ONLY="read-only"
# Roles required for onboarding
ROLES=("Contributor" "User Access Administrator")


# Function to display usage information
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --scope                   [required] Specifies the scope of the onboarding. Can be either '$SUBSCRIPTION_SCOPE' or '$MANAGEMENT_GROUPS_SCOPE'"
  echo "  --subscription_id         [required for '$SUBSCRIPTION_SCOPE' scope] Specifies the subscription id"
  echo "  --management_group_id     [required for '$MANAGEMENT_GROUPS_SCOPE' scope] Specifies the management group id"
  echo "  --onboarding_mode         [required] Specifies the onboard mode for CloudGuard_CGNS. Can be either 'read-only' or 'manage' [default: 'read-only']"
  echo "  --multi_tenant_app_id     [optional] Specifies CloudGuard_CGNS Azure application id - for CloudGuard_CGNS application managed"
  echo "  --single_tenant_app_mode  [optional] Specifies CloudGuard_CGNS Azure application - customer app registration handling"
  echo "  --app_name                [required for single tenant app mode] Specifies the name of the application to be created"
  echo "  --dry_run                 [optional] Specifies whether to run the script in dry-run mode [default: 'false']"
  echo "  --clean                   [optional] Specifies whether to delete all the resources that the script created [default: 'false']"
  echo "  --quiet                   [optional] Specifies whether to quiet all the user interactions [default: 'false']"
  echo "  --help                    Show this help message and exit"
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



# Function to handle errors
exit_with_error() {
  echo "Error: $1"
  usage
  exit 1
}


exit_without_error() {
  green "$1"
  exit 0
}



# Function to set default input values
default_inputs() {
  dry_run="false" #Set default dry-run mode to false
  clean="false"   #delete all the resources that the script created [default: 'false'](except service principale)
  quiet="false" #quiet all the user interactions [default: 'false']
  application_id=""
  sp_id=""
}



# Function to parse input arguments
parse_input() {
  # Parse input arguments
  default_inputs

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --scope)
      scope="$2"
      if [[ -z "$2" || "$2" == --* ]]; then
        exit_with_error "Missing required scope argument value"
      fi
      shift 2
      ;;
    --management_group_id)
      management_group_id="$2"
      if [[ -z "$2" || "$2" == --* ]]; then
        exit_with_error "Missing required management_group_id argument value"
      fi
      shift 2
      ;;
    --onboarding_mode)
      onboarding_mode="$2"
      if [[ -z "$2" || "$2" == --* ]]; then
        exit_with_error "Missing required onboarding_mode argument value"
      fi
      shift 2
      ;;
    --multi_tenant_app_id)
      multi_tenant_app_id="$2"
      if [[ -z "$2" || "$2" == --* ]]; then
        exit_with_error "Missing required multi_tenant_app_id argument value"
      fi
      shift 2
      ;;
    --single_tenant_app_mode)
      single_tenant_app_mode="$2"
      if [[ -z "$2" || "$2" == --* ]]; then
        exit_with_error "Missing required single_tenant_app_mode argument value"
      fi
      shift 2
      ;;
    --app_name)
      app_name_input="$2"
      if [ -z "$app_name_input" ]; then
        exit_with_error "Missing required app_name argument"
      fi
      app_name="$app_name_input"
      shift 2
      ;;
    --subscription_id)        
      subscription_id="$2"
      if [[ -z "$2" || "$2" == --* ]]; then
        exit_with_error "Missing required subscription_id argument value"
      fi
      shift 2
      ;;
    --clean)
      clean="true"
      shift 1
      ;;
    --dry_run)
      dry_run="true"
      shift 1
      ;;
    --quiet)
      quiet="true"
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


# Wrapper function for Azure CLI commands
az_wrapper() {
  if [ "$dry_run" = "true" ]; then
    echo "az $*"
    return 0
  fi

  # do not exit on error, capture it and forward to stdout to be handled by caller
  set +e
  AzOutput=$(az "$@" --only-show-errors 2>&1)
  AzRetVal=$?
  set -e
}



# Function to validate input arguments
validate_inputs() {
  if [ -z "$scope" ]; then
    exit_with_error "Missing required argument: --scope"
  fi

  if [ "$scope" != "$SUBSCRIPTION_SCOPE" ] && [ "$scope" != "$MANAGEMENT_GROUPS_SCOPE" ]; then
    exit_with_error "Invalid scope argument. Can be either '$SUBSCRIPTION_SCOPE' or '$MANAGEMENT_GROUPS_SCOPE'"
  fi

  if [ "$scope" = "$SUBSCRIPTION_SCOPE" ] && [ -z "$subscription_id" ]; then
    exit_with_error "Missing required argument: --subscription_id"
  fi

  if [ "$scope" = "$MANAGEMENT_GROUPS_SCOPE" ] && [ -z "$management_group_id" ]; then
    exit_with_error "Missing required argument: --management_group_id"
  fi

  if [ -z "$onboarding_mode" ]; then
    exit_with_error "Missing required argument: --onboarding_mode"
  fi

  if [ "$onboarding_mode" != "$READ_ONLY" ] && [ "$onboarding_mode" != "manage" ]; then
    exit_with_error "Invalid onboarding_mode argument. Can be either 'read-only' or 'manage'"
  fi

  if [ -z "$multi_tenant_app_id" ] && [ -z "$single_tenant_app_mode" ]; then
    exit_with_error "Missing required argument: --multi_tenant_app_id or --single_tenant_app_mode"
  fi

  if [ -n "$multi_tenant_app_id" ] && [ -n "$single_tenant_app_mode" ]; then
    exit_with_error "Invalid argument: --multi_tenant_app_id and --single_tenant_app_mode cannot be used together"
  fi

  if [ -n "$single_tenant_app_mode" ] && [ -z "$app_name" ]; then
    exit_with_error "Missing required argument: --app_name"
  fi

  if [ "$quiet" = "true" ]; then
    lightblue "\nQuiet mode is enabled."
  fi

  if [ "$dry_run" = "true" ]; then
    lightblue "\nDry_run mode is enabled."
  fi
}



# Function to handle rollback operations
rollback() {
  if [ "$clean" = "true" ]; then
    lightblue "\nClean mode is enabled."
    lightblue "\nWe will delete role-assignment created in the script."
    check_if_user_would_like_to_proceed ""

    lightblue "\nStarts cleaning process"
    if [ -z "$multi_tenant_app_id" ]; then
      # delete role assignments for customer app
      rollback_delete_customer_app
    else
      # delete role assignments for multi-tenant app
      rollback_delete_multi_tenant_sp_role_assignments
    fi
    exit_without_error " \n--------- Clean Completed Successfully --------"
  fi
}



rollback_delete_customer_app() {
  az_wrapper ad app list --filter "displayName eq '$app_name'" --query "[].appId" -o tsv

  if [ $AzRetVal -ne 0 ]; then
    exit_with_error "Failed to list applications with the name: $app_name. $NECESSARY_PERMISSIONS_STR. Error from Azure: \n$AzOutput"
  fi

  application_id="$AzOutput"

  local app_result_count
  app_result_count=$(echo "$application_id" | grep -c '^')

  if [ "$app_result_count" -gt 1 ]; then
      exit_with_error "More than one application found with the name $app_name - Can't decide which app to delete."
  fi

  if [ -z "$application_id" ]; then
      lightblue "\nApplication: $app_name not found."
      return 0
  fi

  rollback_delete_role_assignments "$application_id"

  az_wrapper ad app delete --id "$application_id"

  if [ $AzRetVal -ne 0 ]; then
    exit_with_error "\nFailed to delete application: $app_name, App ID: $application_id."
  fi

  lightblue "\nApplication: $app_name, App ID: $application_id deleted successfully."
}



# Function to prompt user for confirmation
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



# Function to delete multi-tenant service principal role assignments
rollback_delete_multi_tenant_sp_role_assignments(){
  if service_principal_doesnt_exists "$multi_tenant_app_id"; then
      yellow ""
  else
    rollback_delete_role_assignments "$multi_tenant_app_id"
  fi
}


# Function to delete role assignments
rollback_delete_role_assignments(){
  local app_to_delete=$1
  local role_assignments
  local role_assignments_ids
  local space_separated_role_assignments_ids

  az_wrapper role assignment list --scope "$onboarding_scope" --query "[?principalName=='$app_to_delete']" -o json
  if [ $AzRetVal -ne 0 ]; then
    yellow "\nFailed to list role assignments for application ID: $app_to_delete. $NECESSARY_PERMISSIONS_STR. Error from Azure: \n$AzOutput"
  fi

  role_assignments="$AzOutput"
  role_assignments_ids=$(echo "$role_assignments" | jq -r '.[].id')
  space_separated_role_assignments_ids=$(echo "$role_assignments_ids" | tr '\n' ' ')

  lightblue "\nDeleting role assignments"
  az_wrapper role assignment delete --ids "$space_separated_role_assignments_ids"
  if [ $AzRetVal -ne 0 ]; then
    yellow "\nFailed to delete role assignments for application ID: $app_to_delete. $NECESSARY_PERMISSIONS_STR. Error from Azure: \n$AzOutput"
  fi
}



# Function to display user information and required permissions
user_information () {
  lightblue "\nPlease make sure the current user has the required permissions to perform the steps below."
  lightblue "This can be accomplished by granting 'Owner' permission over the '$onboarding_scope' scope, and the 'Global Administrator' role."

  lightblue "\nThe script will execute the following steps:"
  if [ -n "$single_tenant_app_mode" ]; then
    lightblue "- Create a new application for '$onboarding_scope' scope, with role:'Reader', and name:'$app_name'."
    if [ "$onboarding_mode" = "$MANAGE" ]; then
      lightblue "- Assign 'Contributor' and 'User Access Administrator' to application: '$app_name' for '$onboarding_scope' scope."
    fi
  fi  
  if [ -n "$multi_tenant_app_id" ]; then
    lightblue "- Create a service principal for CloudGuard application ID: '$multi_tenant_app_id'."
    lightblue "- Assign 'Reader' role to service principal for '$onboarding_scope' scope."
    if [ "$onboarding_mode" = "$MANAGE" ]; then
      lightblue "- Assign 'Contributor' and 'User Access Administrator' to service principal for '$onboarding_scope' scope."
    fi  
  fi
  lightblue ""
  check_if_user_would_like_to_proceed ""
}


# Function to set the scope for onboarding
set_scope() {
  if [ "$scope" = "$SUBSCRIPTION_SCOPE" ]; then
    scopeVar="$SUBSCRIPTIONS"
    scopeIdVar="$subscription_id"
  elif [ "$scope" = "$MANAGEMENT_GROUPS_SCOPE" ]; then
    scopeVar="$MANAGEMENT_GROUPS"
    scopeIdVar="$management_group_id"
  fi
  onboarding_scope="/$scopeVar/$scopeIdVar"
}



# Function to validate user permissions
validate_user_permissions() {
  local scope_type="$1"

  # Get user's principal name
  local userPrincipalName
  az_wrapper ad signed-in-user show --query "userPrincipalName" --output tsv

  if [ $AzRetVal -ne 0 ]; then
    exit_with_error "Failed to get the signed-in user's principal name. $NECESSARY_PERMISSIONS_STR. Error from Azure: \n$AzOutput"
  fi

  userPrincipalName="$AzOutput"
  lightblue "\nLogged-in user's principal name: '$userPrincipalName."

 # skip validatenuser permissions - Because it is impossible to check the inheritance of permissions in Azure
 # return 0
  local userRoleAssignments
  az_wrapper role assignment list --assignee "$userPrincipalName" --include-inherited --include-groups --scope "$scope_type"

  if [ $AzRetVal -ne 0 ]; then
    exit_with_error "Failed to list role assignments for user: $userPrincipalName. $NECESSARY_PERMISSIONS_STR. Error from Azure: \n$AzOutput"
  fi

  userRoleAssignments="$AzOutput"

  if validate_user_can_assign_role "$userRoleAssignments"; then
    green "\nUser has sufficient permissions"
  else
    yellow "\nUser unauthorized to perform role assignments"
  fi
}


# Function to validate if user has a specific role assignment
validate_user_role_assignment() {
  local role_name="$1"
  local list_role_assignments="$2"

  lightblue "\nChecking if current user has a role of '$role_name'"

  local app_result_count
  app_result_count=$(echo "$list_role_assignments" | jq ".[] | select(.roleDefinitionName==\"$role_name\")" | jq -s '. | length')

  if [[ "$app_result_count" == "0" ]]; then
    return 1
  fi
  return 0
}


# Function to validate if user can assign roles
validate_user_can_assign_role() {
  local user_role_assignments="$1"
  lightblue "\nChecking if the current user has an 'Owner' or 'Application Administrator' role in '$onboarding_scope' scope."

  if validate_user_role_assignment "Owner" "$user_role_assignments"; then
    return 0
  elif validate_user_role_assignment "User Access Administrator" "$user_role_assignments"; then 
    return 0
  fi

  return 1
}


# Function to get application ID
get_app_id() {
  if [ -n "$single_tenant_app_mode" ]; then
    create_cloudguard_app_registration
    app_id="$application_id"
  elif [ -n "$multi_tenant_app_id" ]; then
    create_service_principal_for_multi_tenant_app
    app_id="$multi_tenant_app_id"
  else
    exit_with_error "No valid app mode provided. Please specify either --single_tenant_app_mode or --multi_tenant_app_id."
  fi
}


# only single (non multi) tenant mode
create_cloudguard_app_registration() {

  lightblue "\nCreating a new application for '$onboarding_scope' scope, with role:'Reader', and name:'$app_name'"
  # Create a new service principal with the Reader role
  local sp_info
  az_wrapper ad sp create-for-rbac -n "$app_name" --role "Reader" --scopes "$onboarding_scope" 2>/dev/null
  sp_info="$AzOutput"

  if [ $AzRetVal -ne 0 ]; then
    exit_with_error "Failed to create app registration with role Reader. Error from Azure: \n$AzOutput"
  fi

  lightblue "\nApplication info: $sp_info"
  application_id=$(echo "$sp_info" | jq -r ".appId")
  client_secret=$(echo "$sp_info" | jq -r ".password")


  az_wrapper ad sp show --id "$application_id" --query id --output tsv

  if [ $AzRetVal -ne 0 ]; then
    exit_with_error "Failed to fetch service principal id for application: $application_id. $NECESSARY_PERMISSIONS_STR. Error from Azure: \n$AzOutput"
  fi
  sp_id="$AzOutput"

}



# Function to create service principal for multi-tenant app
create_service_principal_for_multi_tenant_app() {
  # create service principal if required
  if service_principal_doesnt_exists "$multi_tenant_app_id"; then
    lightblue "\nCreating a service principal with '$onboarding_scope' scope for app:'$multi_tenant_app_id'"
    # create service principal for given application id
    az_wrapper ad sp create --id "$multi_tenant_app_id"

    if [ $AzRetVal -ne 0 ]; then
      exit_with_error "Failed to create service principal for application: $multi_tenant_app_id. $NECESSARY_PERMISSIONS_STR. Error from Azure: \n$AzOutput"
    fi

    # fetch service principal id
    sp_id=$(echo  "$AzOutput" | jq -r '.id')
  else
    lightblue "\nService principal already exists. proceed with existing service principal id: '$sp_id'"
  fi
}


# Function to check if service principal does not exist
service_principal_doesnt_exists() {
  local app_id=$1
  az_wrapper ad sp show --id "$app_id" --query id --output tsv
  sp_id="$AzOutput"

  if [ $AzRetVal -ne 0 ] || [ -z "$sp_id" ]; then
    lightblue "Service principal doesn't exists for application $app_id"
    return 0
  fi
  lightblue "Service principal $sp_id exists for application $app_id"
  return 1
}


# Function to create role assignments for CloudGuard app
create_role_assignments_for_cloudguard_app() {
  local app_id=$1
  if [ -z "$sp_id" ]; then
    # fetch service principal id if it has not been set yet
    az_wrapper ad sp show --id "$app_id" --query id --output tsv

    if [ $AzRetVal -ne 0 ]; then
      exit_with_error "Failed to fetch service principal id for application: $app_id. $NECESSARY_PERMISSIONS_STR. Error from Azure: \n$AzOutput"
    fi

    sp_id="$AzOutput"
  fi

  app_add_role_assignment_if_needed "$app_id" "$onboarding_scope" "Reader"
  if [[ "$onboarding_mode" = "manage" ]]; then
	for role in "${ROLES[@]}"; do
       app_add_role_assignment_if_needed "$app_id" "$onboarding_scope" "$role"
    done
  fi
}


# Function to add role assignment if needed
app_add_role_assignment_if_needed() {
  local app_id=$1
  local scope=$2
  local role=$3

  local role_assignment_id
  az_wrapper role assignment list --assignee "$app_id" --role "$role" --scope "$scope"

  if [ $AzRetVal -ne 0 ]; then
    exit_with_error "Failed to list role assignments for application: $app_id. $NECESSARY_PERMISSIONS_STR. Error from Azure: \n$AzOutput"
  fi

  if [ "$(echo  "$AzOutput" | jq -e '. | length > 0')" = "true" ]; then
    role_assignment_id=$(echo "$AzOutput" | jq -r '.[0].id')
  fi

  if [ -z "$role_assignment_id" ]; then
    # role assignment does not exists, create it
    lightblue "\nCreating '$role' role assignment for app '$app_id'"
    az_wrapper role assignment create --assignee "$app_id" --role "$role" --scope "$scope"
    if [ $AzRetVal -ne 0 ]; then
      exit_with_error "Failed to create $role role assignment for application:$app_id. Error from Azure: \n$AzOutput"
    fi
  else
    lightblue "\n'$role' role assignment exists for app '$app_id'"
  fi
}



# Function to print onboarding parameters
print_onboarding_parameters() {
  az_wrapper account show --query "tenantId" -o tsv

  if [ $AzRetVal -ne 0 ]; then
    yellow "Failed to get tenant id. $NECESSARY_PERMISSIONS_STR. Error from Azure: \n$AzOutput"
  fi
  tenant_id="$AzOutput"

  lightblue "Tenant ID:                   $tenant_id"

  if [ "$scope" = "$SUBSCRIPTION_SCOPE" ]; then
    lightblue "Subscription ID:             $subscription_id"
  elif [ "$scope" = "$MANAGEMENT_GROUPS_SCOPE" ]; then
    lightblue "Management Group ID:         $management_group_id"
  fi
}


# Function to print service principal parameters
print_onboarding_parameters_service_principal() {
  lightblue "\n\n-----Outputs-----"

  lightblue "Service Principal ID:        $sp_id"
}

# Function to print customer app parameters
print_onboarding_parameters_customer_app() {
  yellowb "\nThe output includes credentials that you must protect, and can only be viewed once. \nBe sure that you do not include these credentials in your code or check the credentials into your source control. \nFor more information, see https://aka.ms/azadsp-cli"

  lightblue "\n\n-----Outputs-----"

  lightblue "Application(client) ID:      $application_id"
  lightblue "Secret Key:                  $client_secret"
}


#########################
######### Main ##########
#########################

main() {
  parse_input "$@"
  validate_inputs
  set_scope
  if [ "$clean" = "true" ]; then
    rollback
  fi
  user_information
  validate_user_permissions "$onboarding_scope"

  app_id=""
  get_app_id

  create_role_assignments_for_cloudguard_app "$app_id"


  # script output handling
  if [ -z "$multi_tenant_app_id" ]; then
    print_onboarding_parameters_customer_app
  else
    print_onboarding_parameters_service_principal
  fi
  print_onboarding_parameters


  #print_onboarding_parameters_service_principal

  #print_onboarding_parameters
  
  green " \n--------- CloudGuard Network Security app registered Successfully --------\n"
  lightblue "\nPlease go back to the CloudGuard Network Security onboarding wizard to complete the onboarding process\n"

}

main "$@"


