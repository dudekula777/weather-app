terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "weather-app-s3-buscket"
    key           = "weather-app/terraform.tfstate"
    region        = "us-east-1"
    use_lockfile  = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "minikube" {
  ami           = "ami-0c02fb55956c7d316" # Example Amazon Linux 2
  instance_type = "t3.medium"

  tags = {
    Name = "minikube-server"
  }
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

output "instance_public_ip" {
  value = aws_instance.minikube.public_ip
}
