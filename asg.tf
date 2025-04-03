# Launch template
resource "aws_launch_template" "webapp_lt" {
  name_prefix   = "webapp_lt_"
  image_id      = var.aws_ami_id
  instance_type = var.aws_instance_type
  key_name      = var.aws_instance_key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.webapp_sg.id]
  }

  user_data = filebase64(var.ec2_user_data)
  

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webapp-instance-byASG"
    }
  }
}



# Create ASG
resource "aws_autoscaling_group" "webapp_asg" {
  name                      = "csye6225_asg"
  min_size                  = 3
  max_size                  = 5
  desired_capacity          = 3
  vpc_zone_identifier       = aws_subnet.private[*].id
  health_check_type         = "EC2"
  health_check_grace_period = 10

  launch_template {
    id      = aws_launch_template.webapp_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.webapp_tg.arn]

  tag {
    key                 = "AutoScalingGroup"
    value               = "TagPropertyLinks"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "webapp-instance"
    propagate_at_launch = true
  }
}


# autoscaling policies：
# 扩展策略：当平均 CPU 利用率超过 5% 时，增加一个实例
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "当 CPU 利用率超过 5% 时触发扩展策略"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}

# 收缩策略：当平均 CPU 利用率低于 3% 时，减少一个实例
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 3
  alarm_description   = "当 CPU 利用率低于 3% 时触发收缩策略"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}