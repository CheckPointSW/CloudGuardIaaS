variable "app-name-con" {
  default = "webapp-con"
}
variable "docker-image" {
  default = "bkimminich/juice-shop"
}
variable "app-name-direct" {
  default = "webapp-direct"
}
variable "app-name-vm" {
  default = "webapp-vm"
}
variable "vmspoke-publisher" {
    default = "bitnami"
}
variable "vmspoke-offer" {
    default = "nginxstack"
}
variable "vmspoke-sku" {
    default = "1-9"
}
variable "vmspoke-sku-enabled" {
    description = "Have you ever deployed this vm spoke before? set to false if not"
    type = bool
    default = true
}