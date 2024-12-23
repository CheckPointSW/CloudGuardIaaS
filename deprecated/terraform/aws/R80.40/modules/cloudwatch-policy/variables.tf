variable "tag_name" {
  type = string
  description = "(Optional) IAM policy name prefix"
  default = "cloudwatch"
}
variable "role" {
  type = string
  description = "A IAM role to attach the cloudwatch policy to it"
}