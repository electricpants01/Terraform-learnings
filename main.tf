provider "aws" {
  region = "us-east-1" # Change to your preferred region
}

# Create a security group
resource "aws_security_group" "basic_web_server_sg" {
  name        = "basic_web_server_sg"
  description = "Allow SSH, HTTP, and ICMP traffic for a basic web server"

  # Allow SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from anywhere
  }

  # Allow HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "BasicWebServerSecurityGroup"
  }
}


# Create an EC2 instance and associate it with the security group
resource "aws_instance" "basic_web_server" {
  availability_zone = "us-east-1a"            # Change to your preferred availability zone
  ami               = "ami-0ebfd941bbafe70c6" # Change to a valid AMI ID for your region
  instance_type     = "t2.micro"              # Change to your preferred instance type
  key_name          = "my_web_server_key_pair"
  security_groups   = [aws_security_group.basic_web_server_sg.name] # Associate the security group

  tags = {
    Name = "BasicWebServerInstance"
  }
}

# Output the public DNS name for SSH access
output "instance_public_dns" {
  value = aws_instance.basic_web_server.public_dns
}

# Output the public IP for SSH access
output "instance_public_ip" {
  value = aws_instance.basic_web_server.public_ip
}