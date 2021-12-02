resource "aws_launch_configuration" "launch_config" {
  name_prefix                 = "web-instance"
  image_id                    = "ami-0a49b025fffbbdac6"
  instance_type               = "t2.micro"
  key_name                    = "mykey-1"
  security_groups             = [aws_security_group.ec2.id]
  associate_public_ip_address = true
  user_data                   = "${data.template_file.provision.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  launch_configuration = aws_launch_configuration.launch_config.id
  min_size             = var.autoscaling_group_min_size
  max_size             = var.autoscaling_group_max_size
  target_group_arns    = [aws_alb_target_group.group.arn]
  vpc_zone_identifier  = aws_subnet.subnet.*.id

  tag {
    key                 = "Name"
    value               = "autoscaling-group"
    propagate_at_launch = true
  }
}
