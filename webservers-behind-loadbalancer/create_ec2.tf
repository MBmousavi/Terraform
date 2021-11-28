variable "instance_count" {
  default = 2
}

resource "aws_instance"  "WebServers" {
  count                  = var.instance_count
  availability_zone      = "eu-central-1a"
  ami                    = "ami-0a49b025fffbbdac6"
  instance_type          = "t2.micro"
  key_name               = "mykey-1"
  vpc_security_group_ids = [aws_security_group.WebServers.id]
  user_data              = "${file("cloud_init.sh")}"
  tags = {
    "Terraform" : "true"
    "Name"      = "WebServer-${count.index + 1}"
         }
}
