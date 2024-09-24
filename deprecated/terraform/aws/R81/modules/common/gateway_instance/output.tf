output "gateway_instance_id" {
  value = aws_instance.gateway_instance.id
}
output "gateway_instance_arn" {
  value = aws_instance.gateway_instance.arn
}
output "gateway_instance_name" {
  value = aws_instance.gateway_instance.tags["Name"]
}
