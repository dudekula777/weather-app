terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "weather-app-s3-buscket"
    key    = "weather-app/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

# Reuse existing key pair (do not create new one)
data "aws_key_pair" "my_key" {
  key_name = "my-ec2-key"
}

# Get latest Ubuntu 20.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Security group for Minikube
resource "aws_security_group" "minikube_sg" {
  name        = "minikube-sg"
  description = "Allow Kubernetes traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance for Minikube
resource "aws_instance" "minikube" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  key_name               = data.aws_key_pair.my_key.key_name   # ✅ fixed
  vpc_security_group_ids = [aws_security_group.minikube_sg.id]

  tags = {
    Name = "minikube-server"
  }
}

# Output EC2 public IP
output "instance_public_ip" {
  value       = aws_instance.minikube.public_ip
  description = "Public IP of the Minikube EC2 instance"
}
