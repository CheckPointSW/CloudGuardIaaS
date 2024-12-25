variable "allocate_and_associate_eip" {
  type = bool
  description = "If set to TRUE, an elastic IP will be allocated and associated with the launched instance"
  default = true
}

variable "eip_name" {
  type = string
  description = "Elastic IP resource name"
  default = "tf-eip"
}

variable "instance_id" {
  type = string
  description = "The instance id of the cloud resource to bind the eip to"
}

variable "association_instance_type" {
  type = string
  description = "The type of cloud resource to bind the eip to"
  default = "EcsInstance"
}