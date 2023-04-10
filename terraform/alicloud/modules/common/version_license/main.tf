locals {
  gw_versions = [
    //"R81-PAYG-NGTP",
   // "R81-PAYG-NGTX",
    "R81-BYOL",
    "R81.10-BYOL",
    "R81.20-BYOL"
  ]
  mgmt_versions = [
    //"R81-PAYG",
    "R81-BYOL",
    "R81.10-BYOL",
    "R81.20-BYOL"
  ]
}

locals {
  gw_values = var.chkp_type == "gateway" ? local.gw_versions : []
  mgmt_values = var.chkp_type == "management" ? local.mgmt_versions : []
 // standalone_values = var.chkp_type == "standalone" ? local.standalone_versions : []
  allowed_values = coalescelist(local.gw_values, local.mgmt_values)//, local.standalone_values)
  is_allowed_type = index(local.allowed_values, var.version_license)
}