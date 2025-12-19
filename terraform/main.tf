provider "aws" {
  region = var.region
}
 

 ## AMI Data Source for Amazon Linux 2 ##
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

## security group for allowing ssh, http, and app port

resource "aws_security_group" "sg" {
  name = "devops-sg"

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
    from_port   = 3000
    to_port     = 3000
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
 
# -------------------------

# Ansible Control Node

# -------------------------

resource "aws_instance" "ansible_control" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  security_groups = [aws_security_group.sg.name]
  # user_data = <<-EOF
  #   #!/bin/bash
  #   sudo yum update -y
  #   sudo amazon-linux-extras | grep ansible
  #   sudo amazon-linux-extras enable ansible2
  #   sudo yum install ansible -y 
  # EOF

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    yum update -y

    # Enable Ansible repo
    amazon-linux-extras enable ansible2

    # Refresh yum metadata
    yum clean metadata
    yum install -y ansible

    # Verify installation
    ansible --version

    # Log completion
    echo "Ansible installed successfully" > /tmp/ansible_installed.txt
    EOF

      tags = { Name = "ansible-control" }

    }
 
# -------------------------

# App Instances

# -------------------------

resource "aws_instance" "app" {
  count         = var.app_count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.sg.name]
  tags = {
    Name = "node-app-${count.index + 1}"
  }
}
 
# -------------------------

# Nginx LB

# -------------------------

resource "aws_instance" "nginx" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.sg.name]
  tags = { Name = "nginx-lb" }
}

 
 resource "null_resource" "copy_ssh_key" {
  depends_on = [aws_instance.ansible_control]

  provisioner "file" {
    source      = "~/.ssh/mykey.pem"
    destination = "/home/ec2-user/.ssh/mykey.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/mykey.pem")
      host        = aws_instance.ansible_control.public_ip
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/mykey.pem")
      host        = aws_instance.ansible_control.public_ip
    }

    inline = [
      "chmod 400 /home/ec2-user/.ssh/mykey.pem"
    ]
  }
}
