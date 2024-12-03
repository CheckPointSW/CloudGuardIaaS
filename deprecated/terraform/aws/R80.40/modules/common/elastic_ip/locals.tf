locals {
  allocate_and_associate_eip_condition = var.allocate_and_associate_eip == true ? 1 : 0
}