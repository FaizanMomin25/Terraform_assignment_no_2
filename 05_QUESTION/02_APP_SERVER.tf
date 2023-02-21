# Create the security group for the app servers

resource "aws_security_group" "ethix-app-sg" {
  name        = "ethix-application"
  description = "Security group for the app servers"
  vpc_id      = aws_vpc.ethix-vpc.id


  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ethix-web-sg.id}"]
  }
}
# Create the app server EC2 instance and attach the app-sg security group
resource "aws_instance" "app_server" {
  ami                    = "ami-0cca134ec43cf708f"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ethix_key.key_name
  vpc_security_group_ids = ["${aws_security_group.ethix-app-sg.id}"]
  subnet_id              = aws_subnet.ethix_private01.id
}