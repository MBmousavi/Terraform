data "aws_availability_zones" "available" {}
data "template_file" "provision" {
  template = "${file("provision.sh")}"
  vars     = {
               database_endpoint = "${aws_db_instance.db.endpoint}"
               database_name     = "${var.database_name}"
               database_password = "${var.database_password}"
               region            = "${var.region}"
             }
}
