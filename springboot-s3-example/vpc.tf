
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags       = { Name = "${var.route53_hosted_zone_name}-vpc" }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id     = aws_vpc.vpc.id
  tags       = { Name = "${var.route53_hosted_zone_name}-Gateway" }
}

resource "aws_route" "route" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_subnet" "subnet" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  tags                    = { Name = "public-${element(data.aws_availability_zones.available.names, count.index)}" }
}

resource "aws_security_group" "alb" {
  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags          = { Name = "${var.route53_hosted_zone_name}-alb-security-group" }
}

resource "aws_security_group" "ec2" {
  name           = "terraform_security_group"
  description    = "Terraform ec2 security group"
  vpc_id         = aws_vpc.vpc.id

  # Allow outbound internet access.
  egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  tags          = { Name = "${var.route53_hosted_zone_name}-ec2-security-group" }
}

resource "aws_security_group" "rds" {
  name        = "terraform_rds_security_group"
  description = "Terraform RDS MySQL server Security group"
  vpc_id      = aws_vpc.vpc.id
  # Keep the instance private by only allowing traffic from the web server.
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags          = { Name = "${var.route53_hosted_zone_name}-rds-security-group" }
}

