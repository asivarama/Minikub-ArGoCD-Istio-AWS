provider "aws" {
  region = var.region
}

resource "aws_instance" "minikube" {
  ami           = "ami-0f58b397bc5c1f2e8" # Ubuntu 22.04 LTS - ap-south-1
  instance_type = var.instance_type
  key_name      = var.key_name

  root_block_device {
    volume_size = var.disk_size
    volume_type = "gp2"
  }

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "minikube-argocd-istio"
  }

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
