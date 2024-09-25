provider "aws" {
  region = var.aws_region
}

# VPC y subnets
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true   # Enable DNS resolution
  enable_dns_hostnames = true   # Enable DNS hostnames
  tags = {
    Name = "todo-app-vpc"
  }
}

# Public subnets
resource "aws_subnet" "subnet_1" {
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.subnet_1_cidr
  availability_zone      = var.availability_zone_1
  map_public_ip_on_launch = true  # Ensures public IP for instances
  tags = {
    Name = "todo-app-subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.subnet_2_cidr
  availability_zone      = var.availability_zone_2
  map_public_ip_on_launch = true  # Ensures public IP for instances
  tags = {
    Name = "todo-app-subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "todo-app-igw"
  }
}

# Route Table for public access
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "todo-app-public-rt"
  }
}

# Associate the route table with the public subnets
resource "aws_route_table_association" "subnet_1_association" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet_2_association" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr_block]  # Restrict to trusted IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "todo-app-rds-sg"
  }
}

# Subnet Group para la base de datos
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "todo-app-rds-subnet-group"
  subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

  tags = {
    Name = "todo-app-rds-subnet-group"
  }
}

# RDS PostgreSQL
resource "aws_db_instance" "todo_app_db" {
  identifier                 = "todo-app-db"
  allocated_storage          = var.db_allocated_storage
  engine                     = "postgres"
  engine_version             = var.db_engine_version
  instance_class             = var.db_instance_class
  db_name                    = var.db_name
  username                   = var.db_username
  password                   = var.db_password
  db_subnet_group_name       = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids     = [aws_security_group.rds_sg.id]
  publicly_accessible        = true  # Set to true to allow public access
  skip_final_snapshot        = true
  backup_retention_period    = var.backup_retention_period
  storage_encrypted          = true
  auto_minor_version_upgrade = true
  multi_az                   = var.multi_az

  tags = {
    Name        = "todo-app-db"
    Environment = "Production"
    Terraform   = "true"
  }
}