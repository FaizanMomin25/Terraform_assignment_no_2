#######WEB_SERVER

# Create the security group for the web servers

resource "aws_security_group" "ethix-web-sg" {
  name        = "web-sg"
  description = "Security group for the web servers"
  vpc_id      = aws_vpc.ethix-vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ethix-alb-sg.id}"]
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ethix-alb-sg.id}"]
  }
}

# Create the web server EC2 instance and attach the web-sg security group

resource "aws_instance" "web_server" {
  ami                    = "ami-0cca134ec43cf708f"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ethix_key.key_name
  vpc_security_group_ids = ["${aws_security_group.ethix-web-sg.id}"]
  subnet_id              = aws_subnet.ethix_public01.id
}
