resource "random_id" "unique_lb_id" {
  keepers = {
    prefix = var.prefix_name
  }
  byte_length = 8
}
resource "aws_lb" "load_balancer" {
  name  = substr(format("%s-%s", "${var.prefix_name}-LB", random_id.unique_lb_id.hex), 0, 32)
  load_balancer_type = var.load_balancers_type == "gateway" ? "gateway" : var.load_balancers_type == "Network Load Balancer" ? "network": "application"
  internal = var.load_balancers_type == "gateway" ? "false" : var.internal
  subnets = var.instances_subnets
  security_groups = var.security_groups
  tags = var.tags
  enable_cross_zone_load_balancing = var.cross_zone_load_balancing
}
resource "aws_lb_target_group" "lb_target_group" {
  name  = substr(format("%s-%s", "${var.prefix_name}-TG", random_id.unique_lb_id.hex), 0, 32)
  vpc_id = var.vpc_id
  protocol = var.load_balancer_protocol
  port = var.target_group_port
  health_check {
    port     =  var.load_balancers_type != "gateway" ? var.health_check_port : 8117
    protocol =  var.load_balancers_type != "gateway" ? var.health_check_protocol : "TCP"
  }
}
resource "aws_lb_listener" "lb_listener" {
  depends_on = [aws_lb.load_balancer, aws_lb_target_group.lb_target_group]
  load_balancer_arn = aws_lb.load_balancer.arn
  certificate_arn = var.certificate_arn
  protocol = var.load_balancers_type != "gateway" ? var.load_balancer_protocol : null
  port = var.load_balancers_type != "gateway" ? var.listener_port : null
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}
