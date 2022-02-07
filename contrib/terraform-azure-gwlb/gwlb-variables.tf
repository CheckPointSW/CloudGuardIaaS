variable "gwlb-vmss-agreement" {
    description = "Have you ever deployed a ckp management before? set to false if not"
    type        = bool
    default     = true
}
variable gwlb-name {
    description = "Choose the name"
    type        = string
    default     = "ckpgwlbvmss"
}
variable gwlb-size {
    description = "Choose the name"
    type        = string
    default     = "Standard_DS2_v2"
}
variable gwlb-vmss-min {
    description = "The min number of gateways"
    type        = string
    default     = "2"
}
variable gwlb-vmss-max {
    description = "The max number of gateways"
    type        = string
    default     = "3"
}