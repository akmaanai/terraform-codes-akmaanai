provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "for-remote-state-terra"
    key    = "devops/sg.auto.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "vpc-main" {
  backend = "s3"
  config = {
    bucket = "for-remote-state-terra"
    key    = "devops/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "latest_version" { #INFORMATION ABOUT LATEST VERSION OF AMI
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

resource "aws_instance" "Server" {
  ami                    = data.aws_ami.latest_version.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.VPC-SG.id]
  subnet_id              = data.terraform_remote_state.vpc-main.outputs.public_subnet_ids[0]
  user_data              = <<EOF
  #!/bin/bash
  yum -y update
  yum -y install httpd
  echo "<h2>Webserver from Aku</h2>" > /var/www/html/index.html
  sudo service httpd start
  chkconfig httpd on
  EOF
  tags = {
    "Name"  = "Web-Server"
    "Owner" = "Akmaanai"
  }
}

resource "aws_security_group" "VPC-SG" {
  name   = "DevopsSG"
  vpc_id = data.terraform_remote_state.vpc-main.outputs.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc-main.outputs.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "server-sg" {
  value = aws_security_group.VPC-SG.id
}
