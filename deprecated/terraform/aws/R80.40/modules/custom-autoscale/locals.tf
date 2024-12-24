locals {
  asg_name = format("%s%s-servers", var.prefix != "" ? format("%s-", var.prefix) : "", var.asg_name)

  regex_valid_server_ami = "^(ami-(([0-9a-f]{8})|([0-9a-f]{17})))?$"
  // Will fail if var.server_ami is invalid
  regex_server_ami = regex(local.regex_valid_server_ami, var.server_ami) == var.server_ami ? 0 : "Amazon Machine Image ID must be in the form ami-xxxxxxxx or ami-xxxxxxxxxxxxxxxxx"

  provided_target_groups_condition = var.servers_target_groups != "" ? true : false
}