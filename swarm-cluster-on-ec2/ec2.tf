
data "aws_vpc" "default" {
  default = true
}

resource "aws_instance"  "swarm" {
  count                  = var.instance_count
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.swarm-sg.id]
  user_data              = "${file("cloud_init.sh")}"
  tags = {
    "Terraform" : "true"
    "Name"      = "Swarm-${count.index + 1}"
         }
}

resource "aws_security_group" "swarm-sg" {
  name = "Swarm security group"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "instance_public_ip" {
  value       = aws_instance.swarm.*.public_ip
}
