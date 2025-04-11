# Launch template
resource "aws_launch_template" "webapp_lt" {
  name_prefix   = "webapp_lt_"
  image_id      = var.aws_ami_id
  instance_type = var.aws_instance_type
  key_name      = var.aws_instance_key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.webapp_sg.id]
  }

  # user_data = filebase64(var.ec2_user_data)
  user_data = base64encode(<<-EOT
    #!/bin/bash
    touch /opt/C.txt
    sudo aws s3 cp s3://configbucket261447demo/cloud_watch_agent.json /opt/csye6225/webappFlask/config/cloud_watch_agent.json

    sudo cat <<EOF > /opt/csye6225/webappFlask/app/webapp.env
    MYSQL_USERNAME=${var.db_username}
    MYSQL_PASSWORD=${random_password.db_password.result}

    WEBAPP_SECRET_KEY=${jsondecode(data.aws_secretsmanager_secret_version.webapp_credentials_version.secret_string)["WEBAPP_SECRET_KEY"]}
    WEBAPP_AES_SECRET_KEY=${jsondecode(data.aws_secretsmanager_secret_version.webapp_credentials_version.secret_string)["WEBAPP_AES_SECRET_KEY"]}
    WEBAPP_PUBLIC_KEY=${jsondecode(data.aws_secretsmanager_secret_version.webapp_credentials_version.secret_string)["WEBAPP_PUBLIC_KEY"]}
    WEBAPP_PRIVATE_KEY=${jsondecode(data.aws_secretsmanager_secret_version.webapp_credentials_version.secret_string)["WEBAPP_PRIVATE_KEY"]}

    DB_HOST=${split(":", aws_db_instance.rds_instance.endpoint)[0]}

    AWS_S3_REGION_NAME=${var.aws_region}
    AWS_S3_BUCKET_NAME=${aws_s3_bucket.webappbucket.bucket}
    EOF

    sudo chown csye6225_user:csye6225 /opt/csye6225/webappFlask/app/webapp.env 
    sudo chown csye6225_user:csye6225 /opt/csye6225/webappFlask/config/cloud_watch_agent.json

    sudo mkdir -p /var/log/csye6225/webapp_log/
    sudo touch /var/log/csye6225/webapp_log/flaskapp.log
    sudo chown -R csye6225_user:csye6225 /var/log/csye6225

    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/csye6225/webappFlask/config/cloud_watch_agent.json -s
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status

    sudo systemctl enable amazon-cloudwatch-agent

    sudo systemctl enable webappFlask
    sudo systemctl start webappFlask.service
  EOT
  )
  

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webapp-instance-byASG"
    }
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 8
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted            = true
      kms_key_id           = data.aws_kms_key.ec2_key.arn
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
    value               = "asg-webapp-instance"
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