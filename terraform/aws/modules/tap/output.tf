output "Deployment" {
  value = "Finalizing instances configuration may take up to 20 minutes after deployment is finished."
}

output "tap-sensor_instance_id" {
  value = aws_instance.tap_gateway.id
}
output "tap-sensor_instance_name" {
  value = aws_instance.tap_gateway.tags.Name
}
output "tap-sensor_instance_public_ip" {
  value = aws_instance.tap_gateway.public_ip
}

output "tap-traffic_mirror_target_id" {
  value = aws_cloudformation_stack.tap_target_and_filter.outputs["TrafficMirrorTargetId"]
}
output "tap-traffic_mirror_filter_id" {
  value = aws_cloudformation_stack.tap_target_and_filter.outputs["TrafficMirrorFilterId"]
}

output "tap-tap_lambda_name" {
  value = aws_lambda_function.tap_lambda.function_name
}
output "tap-termination_lambda_name" {
  value = aws_lambda_function.tap_termination_lambda.function_name
}