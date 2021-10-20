variable "private_route_table" {
  type = string
  description = "Sets '0.0.0.0/0' route to the Gateway instance in the specified route table (e.g. rtb-12a34567)"
  default=""
}
variable "internal_eni_id" {
  type = string
  description = "The internal-eni of the security gateway"
}