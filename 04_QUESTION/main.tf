data "aws_ami" "this_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

//FOR VPC
resource "aws_vpc" "this_vpc" {
}

//FOR SUBNETS
resource "aws_subnet" "this_public_subnet" {
  vpc_id            = aws_vpc.this_vpc.id
  cidr_block        = element(var.public_cidr_block, count.index)
  availability_zone = element(var.availability_zone, count.index)
  count             = 2
}
resource "aws_subnet" "this_private_subnet" {
  vpc_id            = aws_vpc.this_vpc.id
  cidr_block        = element(var.private_cidr_block, count.index)
  availability_zone = element(var.availability_zone, count.index)
  count             = 2
}

//FOR INTERNET GATEWAY AND ELASTIC IP
resource "aws_internet_gateway" "this_igw" {
  vpc_id = aws_vpc.this_vpc.id
}
resource "aws_eip" "this_eip" {
  vpc = true
}

//FOR NAT GATEWAY
resource "aws_nat_gateway" "this_nat_gateway" {
  allocation_id = aws_eip.this_eip.id
  subnet_id     = aws_subnet.this_public_subnet[0].id
}

//FOR ROUTE TABLE AND ROUTE
resource "aws_route_table" "this_pub_route_table" {
  vpc_id = aws_vpc.this_vpc.id
}

resource "aws_route" "this_pub_route" {
  route_table_id         = aws_route_table.this_pub_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this_igw.id
}

resource "aws_route_table" "this_pri_route_table" {
  vpc_id = aws_vpc.this_vpc.id
}

resource "aws_route" "this_pri_route" {
  route_table_id         = aws_route_table.this_pri_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.this_nat_gateway.id
}

//FOR SUBNET ASSOCIATION
resource "aws_route_table_association" "this_public_rt_asso" {
  count          = length(var.public_cidr_block)
  subnet_id      = aws_subnet.this_public_subnet[count.index].id
  route_table_id = aws_route_table.this_pub_route_table.id
}
resource "aws_route_table_association" "this_private_rt_asso" {
  count          = length(var.private_cidr_block)
  subnet_id      = aws_subnet.this_private_subnet[count.index].id
  route_table_id = aws_route_table.this_pri_route_table.id
}

//FOR APP SG
resource "aws_security_group" "this_app_sg" {
  name   = "app-sg"
  vpc_id = aws_vpc.this_vpc.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    iterator = ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//FOR SSH
resource "aws_key_pair" "this_ssh_key" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_public_key_path)
}

//FOR APP INSTANCE
resource "aws_instance" "this_ec2_instance" {
  ami                    = data.aws_ami.this_ami.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.this_app_sg.id}"]
  subnet_id              = aws_subnet.this_private_subnet[0].id
  key_name               = aws_key_pair.this_ssh_key.key_name
}

resource "aws_security_group" "this_RDS_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.this_vpc.id

  dynamic "ingress" {
    for_each = var.rds_ingress_rules
    iterator = ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "this_pri_subnet_grp" {
  name       = "rds-db-subnet"
  subnet_ids = aws_subnet.this_private_subnet[*].id
}

resource "aws_db_instance" "this_db_instance" {
  allocated_storage          = 10
  identifier                 = var.identifier
  db_name                    = var.db_name
  engine                     = var.engine
  engine_version             = var.engine_version
  instance_class             = var.instance_class
  username                   = var.username
  password                   = random_password.password.result
  skip_final_snapshot        = true
  db_subnet_group_name       = aws_db_subnet_group.this_pri_subnet_grp.name
  vpc_security_group_ids     = ["${aws_security_group.this_RDS_sg.id}"]
  port                       = var.port
  publicly_accessible        = false
  deletion_protection        = false
  backup_retention_period    = var.backup_retention_period
  auto_minor_version_upgrade = true
}