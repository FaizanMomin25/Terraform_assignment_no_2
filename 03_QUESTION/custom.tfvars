//FOR VPC
cidr_block         = "10.0.0.0/16"
public_cidr_block  = ["10.0.0.0/24", "10.0.1.0/24"]
private_cidr_block = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zone  = ["ap-south-1a", "ap-south-1b"]

//FOR SSH
ssh_key_name        = "ce-ssh-key"
ssh_public_key_path = "/root/.ssh/id_rsa.pub"

//FOR ALB
lb_name = "CE-alb"
lb_type = "application"