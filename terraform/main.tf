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

variable "public_key" {
  type        = string
  description = "Public key content for EC2 key pair"
}
variable "ubuntu_ami" {
  default = "ami-0fb0b230890ccd1e6" # Ubuntu 20.04 LTS in us-east-1
  
}
resource "aws_key_pair" "my_key" {
  key_name   = "my-ec2-key"
  public_key = var.public_key
}

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
  ami                    = var.ubuntu_ami
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.minikube_sg.id]

  tags = {
    Name = "minikube-server"
  }
}

# Output the public IP of the EC2 instance
output "instance_public_ip" {
  value       = aws_instance.minikube.public_ip
  description = "Public IP of the Minikube EC2 instance"
}
