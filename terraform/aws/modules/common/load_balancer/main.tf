resource "aws_lb" "load_balancer" {
  name  = substr(format("%s-%s", "${var.prefix_name}-LB", replace(uuid(), "-", "")), 0, 32)
  load_balancer_type = var.load_balancers_type == "Network Load Balancer" ? "network": "application"
  internal = var.internal
  subnets = var.instances_subnets
  security_groups = var.security_groups
  tags = var.tags
}
resource "aws_lb_target_group" "lb_target_group" {
  name  = substr(format("%s-%s", "${var.prefix_name}-TG", replace(uuid(), "-", "")), 0, 32)
  vpc_id = var.vpc_id
  protocol = var.load_balancer_protocol
  port = var.target_group_port
}
resource "aws_lb_listener" "lb_listener" {
  depends_on = [aws_lb.load_balancer, aws_lb_target_group.lb_target_group]
  load_balancer_arn = aws_lb.load_balancer.arn
  protocol = var.load_balancer_protocol
  port = var.listener_port
  certificate_arn = var.certificate_arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}