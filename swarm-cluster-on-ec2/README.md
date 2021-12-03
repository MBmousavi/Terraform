1- Create 3 ec2 instances with Terraform. Do it with `tarraform plan` then `terraform apply`.

There is a output variable that returns the IP addresses of the ec2 instances. Put these IPs into Ansible inventory file.

2- Run the ansible play book with `ansible-playbook -v swarm.yaml`
