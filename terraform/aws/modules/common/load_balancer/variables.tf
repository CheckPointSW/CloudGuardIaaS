variable "instances_subnets" {
  type = list(string)
  description = "Select at least 2 public subnets in the VPC. If you choose to deploy a Security Management Server it will be deployed in the first subnet"
}
variable "prefix_name" {
  type = string
  description = "Load Balancer and Target Group prefix name"
  default = "quickstart"
}
variable "internal" {
  type = bool
  description = "Select 'true' to create an Internal Load Balancer."
  default = false
}
variable "security_groups" {
  type = list(string)
  description = "A list of security group IDs to assign to the LB. Only valid for Load Balancers of type application"
}
variable "tags" {
  type = map(string)
  description = "A map of tags to assign to the load balancer."
}
variable "vpc_id" {
  type = string
}
variable "load_balancers_type" {
  type = string
  description = "Use Network Load Balancer if you wish to preserve the source IP address and Application Load Balancer if you wish to use content based routing"
  default = "Network Load Balancer"
}
variable "load_balancer_protocol" {
  type = string
  description = "The protocol to use on the Load Balancer."
}
variable "target_group_port" {
  type = number
  description = "The port on which targets receive traffic."
}
variable "listener_port" {
  type = string
  description = "The port on which the load balancer is listening."
}
variable "certificate_arn" {
  type = string
  description = "The ARN of the default server certificate. Exactly one certificate is required if the protocol is HTTPS or TLS. "
  default = ""
}
variable "cross_zone_load_balancing"{
 type = bool
 default = false
 description = "Select 'true' to enable cross-az load balancing. NOTE! this may cause a spike in cross-az charges."
}
variable "health_check_port" {
  description = "The health check port"
  type = number
  default = null
}
variable "health_check_protocol" {
  description = "The health check protocol"
  type = string
  default = null
}