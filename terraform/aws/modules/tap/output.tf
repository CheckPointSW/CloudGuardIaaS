output "Deployment" {
  value = "Finalizing instances configuration may take up to 20 minutes after deployment is finished."
}

output "tap-gateway_instance_id" {
  value = aws_instance.tap_gateway.id
}
output "tap-gateway_instance_name" {
  value = aws_instance.tap_gateway.tags.Name
}
output "tap-gateway_instance_public_ip" {
  value = aws_instance.tap_gateway.public_ip
}

output "tap-traffic_mirror_target_id" {
  value = local.trafficMirrorTargetId
}
output "tap-traffic_mirror_filter_id" {
  value = local.trafficMirrorFilterId
}

output "tap-tap_lambda_name" {
  value = aws_lambda_function.tap_lambda.function_name
}
output "tap-tap_lambda_description" {
  value = "The TAP lambda creates traffic-mirror sessions for all mirrorable and non-blacklisted instances in the TAP gateway's vpc. This lambda is invoked during TAP deployment, scheduled events and when an ec2 instance state is changed to Running"
}
output "blacklisted_tags" {
  value = local.blacklisted_tag_pairs_joined
}

output "tap-termination_lambda_name" {
  value = aws_lambda_function.tap_termination_lambda.function_name
}
output "tap-termination_lambda_description" {
  value = "The 'Termination' lambda deletes traffic-mirror sessions for all instances in the TAP gateway's vpc. Should be invoked manually before destroying the environment in order for terraform destroy to finish successfully."
}
