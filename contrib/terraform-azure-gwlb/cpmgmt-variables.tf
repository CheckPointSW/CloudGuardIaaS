variable "mgmt-name" {
    description = "Choose the name of the management"
    default     = "ckpmgmt"
}
variable "mgmt-sku" {
    description = "Choose the plan to deploy"
    default     = "mgmt-byol"
}
variable "mgmt-version" {
    description = "Choose the version to deploy: either r8040, r81 or r8110"
    default     = "r8110"
}
variable "mgmt-size" {
    description = "Choose the vm-size to deploy"
    default     = "Standard_D3_v2"
}
variable "chkp-admin-usr" {
    default = "cpadmin"
}
variable "mgmt-sku-enabled" {
    description = "Have you ever deployed a ckp management before? set to false if not"
    type        = bool
    default     = true
}
variable "mgmt-dns-suffix" {
    description = "This is the public DNS suffix of your mgmt FQDN"
    default     = "testing"
}