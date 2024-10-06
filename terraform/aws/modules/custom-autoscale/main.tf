resource "aws_security_group" "servers_security_group" {
  count = var.deploy_internal_security_group ? 1 : 0
  name_prefix = format("%s_ServersSecurityGroup", local.asg_name)
  description = "Servers security group"
  vpc_id = var.vpc_id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = format("%s_ServersSecurityGroup", local.asg_name) 
  }
}


resource "aws_launch_template" "servers_launch_template" {
  name_prefix = local.asg_name
  network_interfaces {
    associate_public_ip_address = var.allocate_public_address
    security_groups = var.deploy_internal_security_group ? [aws_security_group.servers_security_group[0].id] : [var.source_security_group]
  }
  key_name = var.key_name
  image_id = var.server_ami
  description = "Initial template version"
  monitoring {
    enabled = true
  }
  instance_type = var.servers_instance_type
}
resource "aws_autoscaling_group" "servers_group" {
  name_prefix = local.asg_name
  vpc_zone_identifier = var.servers_subnets
  launch_template {
    name = aws_launch_template.servers_launch_template.name
    version = aws_launch_template.servers_launch_template.latest_version
  }
  min_size = var.servers_min_group_size
  max_size = var.servers_max_group_size
  target_group_arns = local.provided_target_groups_condition ? [var.servers_target_groups] : []

  tag {
    key = "Name"
    value = format("%s%s", var.prefix != "" ? format("%s-", var.prefix) : "", var.server_name)
    propagate_at_launch = true 
  }
}
resource "aws_autoscaling_policy" "scale_up_policy" {
  adjustment_type = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.servers_group.name
  name = "scale_up_policy"
  cooldown = 300
  scaling_adjustment = 1
}
resource "aws_autoscaling_policy" "scale_down_policy" {
  adjustment_type = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.servers_group.name
  name = "scale_down_policy"
  cooldown = 300
  scaling_adjustment = -1
}
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_high" {
  alarm_description = "Scale-up if CPU > 80% for 10 minutes"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  statistic = "Average"
  period = "300"
  evaluation_periods = "2"
  threshold = "80"
  alarm_actions = [aws_autoscaling_policy.scale_up_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.servers_group.name
  }
  comparison_operator = "GreaterThanThreshold"
  alarm_name = "cpu_alarm_high"
}
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_low" {
  alarm_description = "Scale-down if CPU < 60% for 10 minutes"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  statistic = "Average"
  period = "300"
  evaluation_periods = "2"
  threshold = "60"
  alarm_actions = [aws_autoscaling_policy.scale_down_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.servers_group.name
  }
  comparison_operator = "LessThanThreshold"
  alarm_name = "cpu_alarm_low"
}