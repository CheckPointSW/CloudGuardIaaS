output "tap_output" {
  value = module.tap
}

output "tap-gateway_instance_id" {
  value = module.tap.tap-gateway_instance_id
}
output "gateway_instance_name" {
  value = module.tap.tap-gateway_instance_name
}
output "security_group" {
  value = module.tap.tap-security_group
}
output "gateway_instance_public_ip" {
  value = module.tap.tap-gateway_instance_public_ip
}

output "traffic_mirror_filter_id" {
  value = module.tap.tap-traffic_mirror_filter_id
}
output "traffic_mirror_target_id" {
  value = module.tap.tap-traffic_mirror_target_id
}

output "tap_lambda_name" {
  value = module.tap.tap-tap_lambda_name
}
output "tap_lambda_description" {
  value = module.tap.tap-tap_lambda_description
}

output "termination_lambda_name" {
  value = module.tap.tap-termination_lambda_name
}
output "termination_lambda_description" {
  value = module.tap.tap-termination_lambda_description
}