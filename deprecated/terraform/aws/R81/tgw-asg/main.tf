provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "autoscale" {
  source = "../autoscale"
  providers = {
    aws = aws
  }

  vpc_id = var.vpc_id
  subnet_ids = var.gateways_subnets
  gateway_name = var.gateway_name
  gateway_instance_type = var.gateway_instance_type
  key_name = var.key_name
  enable_volume_encryption = var.enable_volume_encryption
  enable_instance_connect = var.enable_instance_connect
  metadata_imdsv2_required = var.metadata_imdsv2_required
  minimum_group_size = var.gateways_min_group_size
  maximum_group_size = var.gateways_max_group_size
  gateway_version = var.gateway_version
  gateway_password_hash = var.gateway_password_hash
  gateway_maintenance_mode_password_hash = var.gateway_maintenance_mode_password_hash
  gateway_SICKey = var.gateway_SICKey
  allow_upload_download = var.allow_upload_download
  enable_cloudwatch = var.enable_cloudwatch
  gateway_bootstrap_script = "echo -e '\nStarting Bootstrap script\n'; echo 'Adding tgw identifier to cloud-version'; cv_path='/etc/cloud-version'\n if test -f \"$cv_path\"; then sed -i '/template_name/c\\template_name: autoscale_tgw' /etc/cloud-version; fi; cv_json_path='/etc/cloud-version.json'\n cv_json_path_tmp='/etc/cloud-version-tmp.json'\n if test -f \"$cv_json_path\"; then cat \"$cv_json_path\" | jq '.template_name = \"'\"autoscale_tgw\"'\"' > \"$cv_json_path_tmp\"; mv \"$cv_json_path_tmp\" \"$cv_json_path\"; fi; echo 'Setting ASN to: ${var.asn}'; clish -c 'set as ${var.asn}' -s; echo -e '\nFinished Bootstrap script\n'"
  gateways_provision_address_type = var.control_gateway_over_public_or_private_address
  management_server =  var.management_server
  configuration_template = var.configuration_template
}

data "aws_region" "current"{}

module "management" {
  providers = {
    aws = aws
  }
  count = local.deploy_management_condition ? 1 : 0
  source = "../management"

  vpc_id = var.vpc_id
  subnet_id = var.gateways_subnets[0]
  management_name = var.management_server
  management_instance_type = var.management_instance_type
  key_name = var.key_name
  allocate_and_associate_eip = true
  volume_encryption = var.enable_volume_encryption ? "alias/aws/ebs" : ""
  enable_instance_connect = var.enable_instance_connect
  disable_instance_termination = var.disable_instance_termination
  metadata_imdsv2_required = var.metadata_imdsv2_required
  iam_permissions = var.management_permissions
  predefined_role = var.management_predefined_role
  management_version = var.management_version
  management_password_hash = var.management_password_hash
  management_maintenance_mode_password_hash = var.management_maintenance_mode_password_hash
  allow_upload_download = var.allow_upload_download
  admin_cidr = var.admin_cidr
  gateway_addresses = var.gateways_addresses
  gateway_management = var.gateway_management
  management_bootstrap_script = "echo -e '\nStarting Bootstrap script\n'; echo 'Adding tgw identifier to cloud-version'; cv_path='/etc/cloud-version'\n if test -f \"$cv_path\"; then sed -i '/template_name/c\\template_name: management_tgw_asg' /etc/cloud-version; fi; cv_json_path='/etc/cloud-version.json'\n cv_json_path_tmp='/etc/cloud-version-tmp.json'\n if test -f \"$cv_json_path\"; then cat \"$cv_json_path\" | jq '.template_name = \"'\"management_tgw_asg\"'\"' > \"$cv_json_path_tmp\"; mv \"$cv_json_path_tmp\" \"$cv_json_path\"; fi; echo 'Configuring VPN community: tgw-community'; [[ -d /opt/CPcme/menu/additions ]] && /opt/CPcme/menu/additions/config-community.sh \"tgw-community\" || /etc/fw/scripts/autoprovision/config-community.sh \"tgw-community\"; echo 'Setting VPN rules'; mgmt_cli -r true add access-layer name 'Inline'; mgmt_cli -r true add access-rule layer Network position 1 name 'tgw-community VPN Traffic Rule' vpn.directional.1.from 'tgw-community' vpn.directional.1.to 'tgw-community' vpn.directional.2.from 'tgw-community' vpn.directional.2.to External_clear action 'Apply Layer' inline-layer 'Inline'; mgmt_cli -r true add nat-rule package standard position bottom install-on 'Policy Targets' original-source All_Internet translated-source All_Internet method hide; echo 'Creating CME configuration'; autoprov_cfg -f init AWS -mn ${var.management_server} -tn ${var.configuration_template} -cn tgw-controller -po Standard -otp ${var.gateway_SICKey} -r ${data.aws_region.current.name} -ver ${split("-", var.gateway_version)[0]} -iam -dt TGW; autoprov_cfg -f set controller AWS -cn tgw-controller -sv -com tgw-community; autoprov_cfg -f set template -tn ${var.configuration_template} -vpn -vd '''' -con tgw-community; ${var.gateways_blades} && autoprov_cfg -f set template -tn ${var.configuration_template} -ia -ips -appi -av -ab; echo -e '\nFinished Bootstrap script\n'"
}