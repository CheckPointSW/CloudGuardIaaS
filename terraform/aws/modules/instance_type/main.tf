locals {
  gw_types = [
    "c5.large",
    "c5.xlarge",
    "c5.2xlarge",
    "c5.4xlarge",
    "c5.9xlarge",
    "c5.18xlarge",
    "c5n.large",
    "c5n.xlarge",
    "c5n.2xlarge",
    "c5n.4xlarge",
    "c5n.9xlarge",
    "c5n.18xlarge"
  ]
  mgmt_types = [
    "m5.large",
    "m5.xlarge",
    "m5.2xlarge",
    "m5.4xlarge",
    "m5.12xlarge",
    "m5.24xlarge"
  ]
}

locals {
  gw_values = var.chkp_type == "gateway" ? local.gw_types : []
  mgmt_values = var.chkp_type == "management" ? local.mgmt_types : []
  sa_values = var.chkp_type == "standalone" ? conca(local.gw_types, local.mgmt_types) : []
  allowed_values = coalesce(local.gw_values, local.mgmt_values, local.sa_values)
  is_allowed_type = index(local.allowed_values, var.instance_type)
}