#///// Provider /////
provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

#///// Variables /////
variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "subnet1_cidr" {
  default = "172.16.0.0/24"
}

variable "IMA" {
  default = "ami-0a49b025fffbbdac6"
}

variable "ec2_type" {
  default = "t2.micro"
}

variable "ssh_key" {
  default = "mykey-1"
}

variable "environment_list" {
  type = list(string)
  default = ["DEV","QA","STAGE","PROD"]
}

#///// VPC /////
resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = "true"
  tags                 = { Name = "VPC1"}
}

resource "aws_subnet" "subnet1" {
  cidr_block              = var.subnet1_cidr
  vpc_id                  = aws_vpc.vpc1.id
  map_public_ip_on_launch = "true"
  tags                    = { Name = "Subnet-1"}
}

resource "aws_internet_gateway" "gateway1" {
  vpc_id = aws_vpc.vpc1.id
  tags   = { Name = "GW-1"}
}

resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.vpc1.id
  tags   = { Name = "RT-1"}

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway1.id
  }
}

resource "aws_route_table_association" "route-subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route_table1.id
}

#///// Security Group /////
resource "aws_security_group" "WebServers" {
  name   = "WebServers"
  vpc_id = aws_vpc.vpc1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#///// EC2 instance /////
resource "aws_instance" "WebServer-1" {
  ami                    = var.IMA
  instance_type          = var.ec2_type
  key_name               = var.ssh_key
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.WebServers.id]
  user_data              = "${file("cloud_init.sh")}"
  tags                   = {
   Environment = var.environment_list[0]
   "Terraform" : "true"
   "Name"      : "WebServer-1"}
}

#///// Output Variables /////
output "instance-dns" {
  value = aws_instance.WebServer-1.public_dns
}
