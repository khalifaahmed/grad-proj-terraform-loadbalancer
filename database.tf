resource "aws_db_subnet_group" "grad_proj_subnet_group" {
  name = "postgres"

  count = var.db_subnet_group ? 1 : 0

  #create a subnet group of known subnet ids
  #subnet_ids = ["${aws_subnet.public1.id}", "${aws_subnet.public2.id}", "${aws_subnet.public3.id}"]

  #create a subnet group containing all public sunbet 
  #subnet_ids = aws_subnet.public.*.id

  #create an individual subnet in each and every availability zone
  subnet_ids = [for i in range(0, length(data.aws_availability_zones.available.names), 1) : aws_subnet.public[i].id]

  tags = {
    Name = "${var.name}_db-subnet-group"
  }
}


resource "aws_db_instance" "grad_proj_db" {
  count                   = var.db_instance ? 1 : 0
  depends_on              = [aws_db_subnet_group.grad_proj_subnet_group]
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "postgres"
  engine_version          = "14.6"
  instance_class          = "db.t3.micro"
  identifier              = "grad-proj-db"
  db_subnet_group_name    = aws_db_subnet_group.grad_proj_subnet_group[0].name 
  availability_zone       = data.aws_availability_zones.available.names[1]
  multi_az                = false
  backup_retention_period = 0
  max_allocated_storage   = 0
  publicly_accessible     = true
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.grad_proj_sg["rds"].id]
  deletion_protection     = false
  db_name                 = "postgres"
  username                = "gradproj"
  password                = "gradproj"
  ca_cert_identifier      = "rds-ca-rsa4096-g1"  
}


output "db_endpoint" {
  value = var.db_instance ? aws_db_instance.grad_proj_db[0].endpoint : ""
}

