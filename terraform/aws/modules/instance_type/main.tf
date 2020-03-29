locals {
  gw_side = [
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
  mgmt_side = [
    "m5.large",
    "m5.xlarge",
    "m5.2xlarge",
    "m5.4xlarge",
    "m5.12xlarge",
    "m5.24xlarge"
  ]
}

locals {
  allowed_values = var.gateway_or_management == "gateway" ? local.gw_side : local.mgmt_side
  is_variable_in_allowed-values = index(local.allowed_values, var.instance_type)
}