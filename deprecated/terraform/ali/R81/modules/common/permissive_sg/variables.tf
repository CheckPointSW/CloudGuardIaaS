variable "vpc_id" {
  type = string
}
variable "resources_tag_name" {
  type = string
  description = "(Optional)"
  default = ""
}
variable "gateway_name" {
  type = string
  description = "(Optional) The name tag of the Security Gateway instances"
  default = "Check-Point-Gateway-tf"
}