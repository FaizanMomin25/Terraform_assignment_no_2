data "aws_ami" "this_dev_ami" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "this_qa_ami" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"] 
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

//FOR VPC IGW AND SUBNET
resource "aws_vpc" "this_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "this_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.this_vpc.id
}

resource "aws_internet_gateway" "this_igw" {
  vpc_id = aws_vpc.this_vpc.id
}

//FOR DEV SG
resource "aws_security_group" "dev_sg" {
  name = "dev-sg"
  vpc_id = aws_vpc.this_vpc.id
  dynamic "ingress" {
    for_each = [22, 80, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

//FOR DEV INSTANCE
resource "aws_instance" "dev_instance" {
  count         = var.ENV == "DEV" ? 2 : 0
  ami           = data.aws_ami.this_dev_ami.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  subnet_id              = aws_subnet.this_subnet.id
}

//FOR QA SG
resource "aws_security_group" "qa_sg" {
  name = "qa_sg"
  vpc_id = aws_vpc.this_vpc.id
  dynamic "ingress" {
    for_each = [22, 8080, 3306]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
//FOR QA INSTANCE
resource "aws_instance" "qa_instance" {
  count         = var.ENV == "QA" ? 1 : 0
  ami           = data.aws_ami.this_qa_ami.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.qa_sg.id]
  subnet_id              = aws_subnet.this_subnet.id
}