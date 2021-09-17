provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "remote" {
    organization = "ZHAZH"
    workspaces {
      name = "terraform-codes"
    }
  }
}
resource "aws_instance" "web" {
  ami                    = "ami-0c2b8ca1dad447f8a"
  instance_type          = "t2.micro"
 /* vpc_id = "${aws_vpc.myVPC.id}"*/
  vpc_security_group_ids = [aws_security_group.mySG.id]
  tags = {
    "Name"  = "Webserver"
    "Owner" = "Akmaanai"
  }
}
/*resource "aws_eip" "ipaddress" {
  instance = "${aws_instance.web.id}"
  
}*/
resource "aws_security_group" "mySG" {
  name        = "devopsSG"
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
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
/*resource "aws_vpc" "myVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "DevopsVPC"
  }
}
resource "aws_subnet" "mysubnet1" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"
  tags = {
    "Name" = "DevopsSubnet1"
  }

}
*/

