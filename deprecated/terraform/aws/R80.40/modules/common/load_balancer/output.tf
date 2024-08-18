output "load_balancer_id" {
  value = aws_lb.load_balancer.id
}
output "load_balancer_arn" {
  value = aws_lb.load_balancer.arn
}
output "load_balancer_url" {
  value = aws_lb.load_balancer.dns_name
}
output "target_group_id" {
  value = aws_lb_target_group.lb_target_group.id
}
output "target_group_arn" {
  value = aws_lb_target_group.lb_target_group.arn
}
output "load_balancer_tags" {
  value = aws_lb.load_balancer.tags
}