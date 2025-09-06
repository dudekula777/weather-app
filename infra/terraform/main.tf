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

# Use existing key pair instead of creating a new one
data "aws_key_pair" "my_key" {
  key_name = "my-ec2-key"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Ubuntu official owner

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Use existing security group instead of creating new
data "aws_security_group" "minikube_sg" {
  filter {
    name   = "group-name"
    values = ["minikube-sg"]
  }
}

resource "aws_instance" "minikube" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  key_name               = data.aws_key_pair.my_key.key_name
  vpc_security_group_ids = [data.aws_security_group.minikube_sg.id]

  tags = {
    Name = "minikube-server"
  }
}

output "instance_public_ip" {
  value       = aws_instance.minikube.public_ip
  description = "Public IP of the Minikube EC2 instance"
}
