#######RDS
resource "aws_security_group" "ethix-rds-sg" {
  name   = "ethix-rds-sg"
  vpc_id = aws_vpc.ethix-vpc.id

  ingress {
    description     = "Allow RDS traffic"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ethix-app-sg.id}"]
  }
}

resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = "rds-subnet-group"
  subnet_ids = ["${aws_subnet.ethix_private01.id}", "${aws_subnet.ethix_private02.id}"]
}

resource "aws_db_instance" "ethix-RDS" {
  db_name                = "cloudethixmysql01"
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = "password"
  vpc_security_group_ids = ["${aws_security_group.ethix-rds-sg.id}"]
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet-group.name
  skip_final_snapshot    = true
}
