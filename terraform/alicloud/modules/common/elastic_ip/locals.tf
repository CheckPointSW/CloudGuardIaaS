locals {
  allocate_and_associate_eip_condition = var.allocate_and_associate_eip == true ? 1 : 0
  // https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/eip_association#instance_type
  association_instance_type_allowed_values = [
    "EcsInstance",
    "SlbInstance",
    "Nat",
    "NetworkInterface"]
  // Will fail if var.association_instance_type is invalid
  validate_association_instance_type = index(local.association_instance_type_allowed_values, var.association_instance_type)

}