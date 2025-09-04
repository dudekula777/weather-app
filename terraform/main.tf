provider "aws" {
  region = "us-east-1"
}

terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "weather-app-s3-buscket"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}


resource "aws_instance" "minikube" {
  ami           = "ami-0360c520857e3138f" # Amazon Linux 2
  instance_type = "t2.medium"

  vpc_security_group_ids = [aws_security_group.minikube_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Install Docker
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo usermod -aG docker ec2-user

              # Install kubectl
              curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
              chmod +x ./kubectl
              sudo mv ./kubectl /usr/local/bin/kubectl

              # Install Minikube
              curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
              chmod +x minikube
              sudo mv minikube /usr/local/bin/

              # Start Minikube with specific driver
              sudo -i
              minikube start --driver=docker --force
              minikube addons enable metrics-server
              
              # Create namespace
              kubectl create namespace weather-app
              
              # Create deployment
              cat <<EOF | kubectl apply -f -
              apiVersion: apps/v1
              kind: Deployment
              metadata:
                name: weather-app-deployment
                namespace: weather-app
                labels:
                  app: weather-app
              spec:
                replicas: 3
                selector:
                  matchLabels:
                    app: weather-app
                template:
                  metadata:
                    labels:
                      app: weather-app
                  spec:
                    containers:
                    - name: weather-app
                      image: ghcr.io/$GITHUB_REPOSITORY:latest
                      ports:
                      - containerPort: 3000
                      env:
                      - name: NODE_ENV
                        value: "production"
                      - name: OPENWEATHER_API_KEY
                        value: "$OPENWEATHER_API_KEY"
                      readinessProbe:
                        httpGet:
                          path: /health
                          port: 3000
                        initialDelaySeconds: 5
                        periodSeconds: 10
                      livenessProbe:
                        httpGet:
                          path: /health
                          port: 3000
                        initialDelaySeconds: 15
                        periodSeconds: 20
              EOF
              
              # Create service
              cat <<EOF | kubectl apply -f -
              apiVersion: v1
              kind: Service
              metadata:
                name: weather-app-service
                namespace: weather-app
              spec:
                selector:
                  app: weather-app
                ports:
                  - protocol: TCP
                    port: 80
                    targetPort: 3000
                type: LoadBalancer
              EOF
              exit
              EOF

  tags = {
    Name = "Minikube-Weather-App"
  }
}

resource "aws_security_group" "minikube_sg" {
  name        = "minikube-security-group"
  description = "Allow SSH, HTTP, HTTPS and Kubernetes ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
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
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.minikube.public_ip
}