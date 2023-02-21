#######LOAD_BALANCER

# Create the security group for the ALB

resource "aws_security_group" "ethix-alb-sg" {
  name        = "ethix-alb-sg"
  description = "Security group for the ALB"
  vpc_id      = aws_vpc.ethix-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the load balancer

resource "aws_lb" "ethix_load_balancer" {
  name               = "ethix-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ethix-alb-sg.id]
  subnets            = [aws_subnet.ethix_public02.id, aws_subnet.ethix_public01.id]
}
