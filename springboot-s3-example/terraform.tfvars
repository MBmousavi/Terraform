region                     = "eu-central-1"
route53_hosted_zone_name   = "example.com"
rds_instance_identifier    = "terraform-mysql"
database_name              = "terraform_test_db"
database_user              = "terraform"
database_password          = "terraform"
autoscaling_group_min_size = 2
autoscaling_group_max_size = 3
certificate_arn            = ""
vpc_cidr                   = "10.0.0.0/16"
