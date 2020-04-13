provider "aws" {
  region = var.region
}

module "autoscale" {
  source = "../../modules/autoscale"

  // --- Environment ---
  prefix = var.prefix
  asg_name = var.asg_name

  // --- VPC Network Configuration ---
  vpc_id = var.vpc_id
  subnet_ids = var.subnet_ids

  // --- Automatic Provisioning with Security Management Server Settings ---
  gateways_provision_address_type = var.gateways_provision_address_type
  managementServer = var.managementServer
  configurationTemplate = var.configurationTemplate

  // --- EC2 Instances Configuration ---
  instances_name = var.instances_name
  instance_type = var.instance_type
  key_name = var.key_name

  // --- Auto Scaling Configuration ---
  minimum_group_size = var.minimum_group_size
  maximum_group_size = var.maximum_group_size
  target_groups = var.target_groups

  // --- Check Point Settings ---
  version_license = var.version_license
  admin_shell = var.admin_shell
  password_hash = var.password_hash
  SICKey = var.SICKey
  enable_instance_connect = var.enable_instance_connect
  allow_upload_download = var.allow_upload_download
  enable_cloudwatch = var.enable_cloudwatch
  bootstrap_script = var.bootstrap_script

  // --- Outbound Proxy Configuration (optional) ---
  proxy_elb_type = var.proxy_elb_type
  proxy_elb_clients = var.proxy_elb_clients
  proxy_elb_port = var.proxy_elb_port
}
