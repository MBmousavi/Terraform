
resource "aws_subnet" "rds" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${length(data.aws_availability_zones.available.names) + count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  tags                    = { Name = "rds-${element(data.aws_availability_zones.available.names, count.index)}" }
}

resource "aws_db_subnet_group" "subnet_rds" {
  name        = "${var.rds_instance_identifier}-subnet"
  description = "Terraform RDS subnet group"
  subnet_ids  = aws_subnet.rds.*.id
}

resource "aws_db_instance" "db" {
  identifier                = var.rds_instance_identifier
  allocated_storage         = 20
  engine                    = "mysql"
  engine_version            = "5.6.35"
  instance_class            = "db.t2.micro"
  parameter_group_name      = "default.mysql5.6"
  name                      = var.database_name
  username                  = var.database_user
  password                  = var.database_password
  db_subnet_group_name      = aws_db_subnet_group.subnet_rds.id
  vpc_security_group_ids    = [aws_security_group.rds.id]
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
}
