resource "aws_elb" "LoadBalancer" {
  name                     = "LoadBalancer"
  availability_zones       = ["eu-central-1b", "eu-central-1a"]
  security_groups          = [aws_security_group.LoadBalancer.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances                   = aws_instance.WebServers.*.id
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    "Terraform" : "true"
  }
}

output "LoadBalancer-URL" {
  value = aws_elb.LoadBalancer.dns_name
}

