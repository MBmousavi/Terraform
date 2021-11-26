provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "LoadBalancer" {
  name          = "LoadBalancer"
  description   = "Allow http/https inbound"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_security_group" "WebServers" {
  name          = "WebServers"
  description   = "Allow http traffic from LoadBalancer"
  ingress {
    from_port        = 80
    to_port          = 80
    security_groups  = [aws_security_group.LoadBalancer.id]
    protocol         = "tcp"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    "Terraform" : "true"
  }
}
resource "aws_security_group" "Database" {
  name          = "Database"
  description   = "Allow database connection from Webservers"
  ingress {
    from_port        = 3306
    to_port          = 3306
    security_groups  = [aws_security_group.WebServers.id]
    protocol         = "tcp"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    "Terraform" : "true"
  }
}
