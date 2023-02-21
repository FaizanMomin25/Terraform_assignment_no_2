//FOR VPC
cidr_block         = "10.0.0.0/16"
public_cidr_block  = ["10.0.0.0/24", "10.0.1.0/24"]
private_cidr_block = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zone  = ["ap-south-1a", "ap-south-1b"]

//FOR SSH
ssh_key_name        = "ce-ssh-key"
ssh_public_key_path = "/root/.ssh/id_rsa.pub"

//FOR DB SUBNET GROUP
private_subnet_group_name = "taiyaki-db-subnet-sg"

//FOR DB INSTANCE
identifier              = "ce-rds"
db_name                 = "ce-db1"
engine                  = "mysql"
engine_version          = "5.7"
instance_class          = "db.t3.micro"
username                = "root"
port                    = 3306
backup_retention_period = 0