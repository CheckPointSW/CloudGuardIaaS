locals {
  gw_types = [
    "ecs.g5ne.large",
    "ecs.g5ne.xlarge",
    "ecs.g5ne.2xlarge",
    "ecs.g5ne.4xlarge",
    "ecs.g5ne.8xlarge",
    "ecs.g7ne.large",
    "ecs.g7ne.xlarge",
    "ecs.g7ne.2xlarge",
    "ecs.g7ne.4xlarge",
    "ecs.g7ne.8xlarge"
  ]
  mgmt_types = [
    "ecs.g6e.large",
    "ecs.g6e.xlarge",
    "ecs.g6e.2xlarge",
    "ecs.g6e.4xlarge",
    "ecs.g6e.8xlarge"
  ]
}

locals {
  gw_values = var.chkp_type == "gateway" ? local.gw_types : []
  mgmt_values = var.chkp_type == "management" ? local.mgmt_types : []
  allowed_values = coalescelist(local.gw_values, local.mgmt_values)
  is_allowed_type = index(local.allowed_values, var.instance_type)
}