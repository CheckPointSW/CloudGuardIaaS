output "standalone_instance_id" {
  value = aws_instance.standalone-instance.id
}
output "standalone_instance_name" {
  value = aws_instance.standalone-instance.tags["Name"]
}
output "standalone_public_ip" {
  value = aws_instance.standalone-instance.public_ip
}
output "standalone_ssh" {
  value = format("ssh -i %s admin@%s", var.key_name, aws_instance.standalone-instance.public_ip)
}
output "standalone_url" {
  value = format("https://%s", aws_instance.standalone-instance.public_ip)
}