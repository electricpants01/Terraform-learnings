provider "aws" {
  region = "us-east-1" # Replace with your preferred AWS region
}

# VPC creation
resource "aws_vpc" "todo_app_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "todo-app-vpc"
    Environment = "dev"
    Project     = "Todo App"
  }
}

# Internet Gateway for the VPC
resource "aws_internet_gateway" "todo_app_igw" {
  vpc_id = aws_vpc.todo_app_vpc.id

  tags = {
    Name        = "todo-app-igw"
    Environment = "dev"
    Project     = "Todo App"
  }
}

# Public Route Table
resource "aws_route_table" "todo_app_public_route_table" {
  vpc_id = aws_vpc.todo_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.todo_app_igw.id
  }

  tags = {
    Name        = "todo-app-public-route-table"
    Environment = "dev"
    Project     = "Todo App"
  }
}

# Subnets within the VPC
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.todo_app_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-1"
    Environment = "dev"
    Project     = "Todo App"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.todo_app_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-2"
    Environment = "dev"
    Project     = "Todo App"
  }
}

# Associate subnets with the public route table
resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.todo_app_public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.todo_app_public_route_table.id
}

# RDS Subnet Group
resource "aws_db_subnet_group" "todo_app_db_subnet_group" {
  name       = "todo-app-db-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name        = "todo-app-db-subnet-group"
    Environment = "dev"
    Project     = "Todo App"
  }
}

# Security group for RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.todo_app_vpc.id
  name   = "todo-app-rds-sg"

  ingress {
    from_port       = 5432 # PostgreSQL port
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [] # Remove reference to Lambda SG
    cidr_blocks = [
      aws_subnet.public_subnet_1.cidr_block, # Replace with your actual subnet CIDR blocks
      aws_subnet.public_subnet_2.cidr_block, # Replace with your actual subnet CIDR blocks
      "0.0.0.0/0",                           # Allow from anywhere (you can restrict this in production)
    ]                                        # Allow from Lambda function subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound traffic to anywhere (you can restrict this in production)
  }

  tags = {
    Name        = "todo-app-rds-sg"
    Environment = "dev"
    Project     = "Todo App"
  }
}

# PostgreSQL RDS instance
resource "aws_db_instance" "todo_app_db" {
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "postgres"
  engine_version      = "16.4"                # Use a compatible version
  instance_class      = var.db_instance_class # Keep your existing instance class variable
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true
  publicly_accessible = false # Ensure the RDS instance is not publicly accessible in prod
  # Associate the custom parameter group that disables SSL
  parameter_group_name = aws_db_parameter_group.todo_app_pg_no_ssl.name

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.todo_app_db_subnet_group.name

  tags = {
    Name        = "todo-app-db"
    Environment = "dev"
    Project     = "Todo App"
  }
}

# Custom RDS Parameter Group to disable SSL
resource "aws_db_parameter_group" "todo_app_pg_no_ssl" {
  name   = "todo-app-pg-no-ssl"
  family = "postgres16" # Ensure this is the correct version for your PostgreSQL RDS instance

  description = "Parameter group to disable SSL for PostgreSQL RDS"

  # Disable SSL by setting rds.force_ssl to 0
  parameter {
    name         = "rds.force_ssl"
    value        = "0"
    apply_method = "immediate"
  }

  tags = {
    Name        = "todo-app-pg-no-ssl"
    Environment = "dev"
    Project     = "Todo App"
  }
}