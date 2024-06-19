provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
module "gateway_load_balancer" {
  source = "../modules/common/load_balancer"

  load_balancers_type = "gateway"
  instances_subnets = var.subnet_ids
  prefix_name = var.gateway_load_balancer_name
  internal = true

  security_groups = []
  tags = {
    x-chkp-management = var.management_server
    x-chkp-template = var.configuration_template
  }
  vpc_id = var.vpc_id
  load_balancer_protocol = "GENEVE"
  target_group_port = 6081
  listener_port = 6081
  cross_zone_load_balancing = var.enable_cross_zone_load_balancing
}

resource "aws_vpc_endpoint_service" "gwlb_endpoint_service" {
depends_on = [module.gateway_load_balancer]
  gateway_load_balancer_arns = module.gateway_load_balancer[*].load_balancer_arn
  acceptance_required        = var.connection_acceptance_required

  tags = {
    "Name" = "gwlb-endpoint-service-${var.gateway_load_balancer_name}"
  }
}

module "autoscale_gwlb" {
  source = "../autoscale-gwlb"
  providers = {
    aws = aws
  }
  depends_on = [module.gateway_load_balancer]

  target_groups = module.gateway_load_balancer[*].target_group_arn
  vpc_id = var.vpc_id
  subnet_ids = var.subnet_ids
  gateway_name = var.gateway_name
  gateway_instance_type = var.gateway_instance_type
  key_name = var.key_name
  enable_volume_encryption = var.enable_volume_encryption
  enable_instance_connect = var.enable_instance_connect
  metadata_imdsv2_required = var.metadata_imdsv2_required
  minimum_group_size = var.minimum_group_size
  maximum_group_size = var.maximum_group_size
  gateway_version = var.gateway_version
  gateway_password_hash = var.gateway_password_hash
  gateway_maintenance_mode_password_hash = var.gateway_maintenance_mode_password_hash
  gateway_SICKey = var.gateway_SICKey
  allow_upload_download = var.allow_upload_download
  enable_cloudwatch = var.enable_cloudwatch
  gateway_bootstrap_script = var.gateway_bootstrap_script
  admin_shell = var.admin_shell
  gateways_provision_address_type = var.gateways_provision_address_type
  allocate_public_IP = var.allocate_public_IP
  management_server = var.management_server
  configuration_template = var.configuration_template
  volume_type = var.volume_type
}

data "aws_region" "current"{}

module "management" {
  providers = {
    aws = aws
  }
  count = local.deploy_management_condition ? 1 : 0
  source = "../management"

  vpc_id = var.vpc_id
  subnet_id = var.subnet_ids[0]
  management_name = var.management_server
  management_instance_type = var.management_instance_type
  key_name = var.key_name
  allocate_and_associate_eip = true
  volume_encryption = var.enable_volume_encryption ? "alias/aws/ebs" : ""
  enable_instance_connect = var.enable_instance_connect
  disable_instance_termination = var.disable_instance_termination
  metadata_imdsv2_required = var.metadata_imdsv2_required
  management_version = var.management_version
  management_password_hash = var.management_password_hash
  management_maintenance_mode_password_hash = var.management_maintenance_mode_password_hash
  allow_upload_download = var.allow_upload_download
  admin_cidr = var.admin_cidr
  admin_shell = var.admin_shell
  gateway_addresses = var.gateways_addresses
  gateway_management = var.gateway_management
  management_bootstrap_script = "echo -e '\nStarting Bootstrap script\n'; cv_json_path='/etc/cloud-version.json'\n cv_json_path_tmp='/etc/cloud-version-tmp.json'\n if test -f \"$cv_json_path\"; then cat \"$cv_json_path\" | jq '.template_name = \"'\"management_gwlb\"'\"' > \"$cv_json_path_tmp\"; mv \"$cv_json_path_tmp\" \"$cv_json_path\"; fi; autoprov_cfg -f init AWS -mn ${var.management_server} -tn ${var.configuration_template} -cn gwlb-controller -po ${var.gateways_policy} -otp ${var.gateway_SICKey} -r ${data.aws_region.current.name} -ver ${split("-", var.gateway_version)[0]} -iam; echo -e '\nFinished Bootstrap script\n'"
  volume_type = var.volume_type
  is_gwlb_iam = true
}
