resource "aws_launch_configuration" "webnodes" {
  image_id        = var.web_ami_id
  instance_type   = "t3.small"
  security_groups = [aws_security_group.web.id]
  user_data       = <<EOF
    #!/bin/bash
    sudo apt install nginx
    sudo systemctl enable nginx --now
    EOF
}

# asg
resource "aws_autoscaling_group" "scalegroup" {
  name                  = "web"
  launch_configuration  = aws_launch_configuration.webnodes.name
  min_size              = 2
  min_elb_capacity      = 2
  wait_for_elb_capacity = 2
  max_size              = 4
  # used for future MetricBeats
  enabled_metrics     = ["GroupInServiceInstances", "GroupTotalInstances"]
  metrics_granularity = "1Minute"
  health_check_type   = "ELB"

  vpc_zone_identifier = [aws_subnet.web.id]
  target_group_arns   = [aws_alb_target_group.web.arn]

  depends_on = [aws_instance.elk]
}

resource "aws_autoscaling_policy" "autopolicy-up" {
  name                   = "web-autopolicy-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.scalegroup.name
}

resource "aws_autoscaling_policy" "autopolicy-down" {
  name                   = "web-autopolicy-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.scalegroup.name
}
# TG
resource "aws_alb_target_group" "web" {
  name                 = "web-alb-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  deregistration_delay = 60

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = "true"
  }

  health_check {
    healthy_threshold = 2
    interval          = 10
  }
}

# ALB
resource "aws_alb" "web" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.web.id]
  security_groups    = [aws_security_group.web.id]

  enable_deletion_protection = false
}

# Listener
resource "aws_alb_listener" "web_listener" {
  load_balancer_arn = aws_alb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.web.arn
  }
}


