data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "WebServers" {
  name          = "WebServers"
  description   = "Allow http and ssh"
  ingress {
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    protocol         = "tcp"
  }
  ingress {
    from_port        = 22
    to_port          = 22
    cidr_blocks      = ["0.0.0.0/0"]
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

resource "aws_instance"  "WebServers" {
  count                  = var.instance_count
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.WebServers.id]
  tags = {
    "Terraform" : "true"
    "Name"      = "WebServer-${count.index + 1}"
         }
}

resource "local_file" "ip" {
  content       = templatefile("inventory.tmpl",
    {
      ec2_hosts = "${aws_instance.WebServers.*.public_ip}"
    }
  )
  filename = var.inventory_file
  depends_on = [ aws_instance.WebServers, ]
}

resource "null_resource" "test_ansible" {
  depends_on = [ local_file.ip, ]
  provisioner "local-exec" {
  command = "sleep 60; ansible -i '${var.inventory_file}' all  --private-key ${var.ssh_key_private} -m ping"
    }
}

resource "null_resource" "install_nginx" {
  depends_on = [ null_resource.test_ansible, ]
  provisioner "local-exec" {
  command = "ansible-playbook -i '${var.inventory_file}'  --private-key ${var.ssh_key_private} nginx_install.yml"
    }
}
