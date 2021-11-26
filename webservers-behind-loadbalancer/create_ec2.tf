resource "aws_instance" "WebServer-1" {
  availability_zone      = "eu-central-1a"
  ami                    = "ami-0a49b025fffbbdac6"
  instance_type          = "t2.micro"
  key_name               = "mykey-1"
  vpc_security_group_ids = [aws_security_group.WebServers.id]
  user_data              = "${file("cloud_init.sh")}"
  tags = {
    "Terraform" : "true"
    "Name"      : "WebServer-1"
         }
}
resource "aws_instance" "WebServer-2" {
  availability_zone      = "eu-central-1b"
  ami                    = "ami-0a49b025fffbbdac6"
  instance_type          = "t2.micro"
  key_name               = "mykey-1"
  vpc_security_group_ids = [aws_security_group.WebServers.id]
  user_data              = "${file("cloud_init.sh")}"
  tags = {
    "Terraform" : "true"
    "Name"      : "WebServer-2"
         }
}
