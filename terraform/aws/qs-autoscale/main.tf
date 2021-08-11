provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_security_group" "external_alb_security_group" {
  count = local.alb_condition ? 1 : 0
  description = "External ALB security group"
  vpc_id = var.vpc_id

  egress {
    from_port = local.encrypted_protocol_condition ? 9443 : 9080
    protocol = "tcp"
    to_port = local.encrypted_protocol_condition ? 9443 : 9080
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = local.provided_port_condition ? var.service_port : local.encrypted_protocol_condition ? 443 : 80
    protocol = "tcp"
    to_port = local.provided_port_condition ? var.service_port : local.encrypted_protocol_condition ? 443 : 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "external_load_balancer" {
  source = "../modules/common/load_balancer"

  load_balancers_type = var.load_balancers_type
  instances_subnets = var.gateways_subnets
  prefix_name = "${var.prefix}-External"
  internal = false
  security_groups = local.alb_condition ? [aws_security_group.external_alb_security_group[0].id] : []
  tags = {}
  vpc_id = var.vpc_id
  load_balancer_protocol = var.load_balancer_protocol
  target_group_port = local.encrypted_protocol_condition ? 9443 : 9080
  listener_port = local.provided_port_condition ? var.service_port : local.encrypted_protocol_condition ? "443" : "80"
  certificate_arn = local.encrypted_protocol_condition ? var.certificate : ""
}

module "autoscale" {
  source = "../autoscale"
  providers = {
    aws = aws
  }

  prefix = var.prefix
  asg_name = var.asg_name
  vpc_id = var.vpc_id
  subnet_ids = var.gateways_subnets
  gateway_name = "${var.provision_tag}-security-gateway"
  gateway_instance_type = var.gateway_instance_type
  key_name = var.key_name
  enable_volume_encryption = var.enable_volume_encryption
  enable_instance_connect = var.enable_instance_connect
  minimum_group_size = var.gateways_min_group_size
  maximum_group_size = var.gateways_max_group_size
  target_groups = list(module.external_load_balancer.target_group_arn)
  gateway_version = var.gateway_version
  gateway_password_hash = var.gateway_password_hash
  gateway_SICKey = var.gateway_SICKey
  allow_upload_download = var.allow_upload_download
  enable_cloudwatch = var.enable_cloudwatch
  gateway_bootstrap_script = "echo -e '\nStarting Bootstrap script\n'; echo 'Adding quickstart identifier to cloud-version'; cv_path='/etc/cloud-version'\n if test -f \"$cv_path\"; then sed -i '/template_name/c\\template_name: autoscale_qs' /etc/cloud-version; fi; cv_json_path='/etc/cloud-version.json'\n cv_json_path_tmp='/etc/cloud-version-tmp.json'\n if test -f \"$cv_json_path\"; then cat \"$cv_json_path\" | jq '.template_name = \"'\"autoscale_qs\"'\"' > \"$cv_json_path_tmp\"; mv \"$cv_json_path_tmp\" \"$cv_json_path\"; fi; echo -e '\nFinished Bootstrap script\n'"
  management_server = local.deploy_management_condition ? "${var.provision_tag}-management" : ""
  configuration_template = local.deploy_management_condition ? "${var.provision_tag}-template" : ""
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
  management_name = "${var.provision_tag}-management"
  management_instance_type = var.management_instance_type
  key_name = var.key_name
  volume_encryption = var.enable_volume_encryption ? "alias/aws/ebs" : ""
  enable_instance_connect = var.enable_instance_connect
  iam_permissions = "Create with read-write permissions"
  management_version = var.management_version
  management_password_hash = var.management_password_hash
  allow_upload_download = var.allow_upload_download
  admin_cidr = var.admin_cidr
  gateway_addresses = var.gateways_addresses
  management_bootstrap_script = "echo -e '\nStarting Bootstrap script\n'; echo 'Adding quickstart identifier to cloud-version'; cv_path='/etc/cloud-version'\n if test -f \"$cv_path\"; then sed -i '/template_name/c\\template_name: management_qs' /etc/cloud-version; fi; cv_json_path='/etc/cloud-version.json'\n cv_json_path_tmp='/etc/cloud-version-tmp.json'\n if test -f \"$cv_json_path\"; then cat \"$cv_json_path\" | jq '.template_name = \"'\"management_qs\"'\"' > \"$cv_json_path_tmp\"; mv \"$cv_json_path_tmp\" \"$cv_json_path\"; fi; echo 'Creating CME configuration'; autoprov_cfg -f init AWS -mn ${var.provision_tag}-management -tn ${var.provision_tag}-template -cn ${var.provision_tag}-controller -po ${var.gateways_policy} -otp ${var.gateway_SICKey} -r ${data.aws_region.current.name} -ver ${split("-", var.gateway_version)[0]} -iam; ${var.gateways_blades} && autoprov_cfg -f set template -tn ${var.provision_tag}-template -ips -appi -av -ab; echo -e '\nFinished Bootstrap script\n'"
}

resource "aws_security_group" "internal_security_group" {
  count = local.deploy_servers_condition ? 1 : 0
  vpc_id = var.vpc_id

  egress {
    from_port = local.provided_port_condition ? var.service_port : local.encrypted_protocol_condition ? 443 : 80
    protocol = "tcp"
    to_port = local.provided_port_condition ? var.service_port : local.encrypted_protocol_condition ? 443 : 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = local.encrypted_protocol_condition ? 443 : 80
    protocol = "tcp"
    to_port = local.encrypted_protocol_condition ? 443 : 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    protocol = "icmp"
    to_port = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "internal_load_balancer" {
  count = local.deploy_servers_condition ? 1 : 0
  source = "../modules/common/load_balancer"

  load_balancers_type = var.load_balancers_type
  instances_subnets = var.servers_subnets
  prefix_name = "${var.prefix}-Internal"
  internal = true
  security_groups = local.alb_condition ? [aws_security_group.internal_security_group[0].id] : []
  tags = {
    x-chkp-management = "${var.provision_tag}-management"
    x-chkp-template = "${var.provision_tag}-template"
  }
  vpc_id = var.vpc_id
  load_balancer_protocol = var.load_balancer_protocol
  target_group_port = local.encrypted_protocol_condition ? 443 : 80
  listener_port = local.encrypted_protocol_condition ? "443" : "80"
  certificate_arn = local.encrypted_protocol_condition ? var.certificate : ""
}

module "custom_autoscale" {
  count = local.deploy_servers_condition ? 1 : 0
  source = "../modules/custom-autoscale"

  prefix = var.prefix
  asg_name = var.asg_name
  vpc_id = var.vpc_id
  servers_subnets = var.servers_subnets
  server_ami = var.server_ami
  server_name = "${var.provision_tag}-server"
  servers_instance_type = var.servers_instance_type
  key_name = var.key_name
  servers_min_group_size = var.gateways_min_group_size
  servers_max_group_size = var.gateways_max_group_size
  servers_target_groups = module.internal_load_balancer[0].target_group_id
  deploy_internal_security_group = local.nlb_condition ? true : false
  source_security_group = local.nlb_condition ? "" : aws_security_group.internal_security_group[0].id
}