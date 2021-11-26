resource "aws_db_instance" "Database" {
  engine                 = "mysql"
  identifier             = "mydatabase"
  engine_version         = "8.0.23"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  name                   = "mydb"
  username               = "admin"
  password               = "Momo321321"
  parameter_group_name   = "default.mysql8.0"
  vpc_security_group_ids = [aws_security_group.Database.id]
}
