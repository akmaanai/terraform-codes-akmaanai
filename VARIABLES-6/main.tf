provider "aws" {
  region = var.region
}
data "aws_ami" "latest_amazon_linux" { #INFORMATION ABOUT LATEST VERSION OF AMI
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}
resource "aws_eip" "ipaddress" { #ELASTIC IP ADDRESS that REFERENCED TO NEW CREATED EC2
  instance = aws_instance.server.id
  tags = merge(var.common_tags, { Name = "Server EIP"})
  //tags = var.common_tags
 /* tags = {
    Name    = "Server IP"
    Owner   = "Akmaanai Zhumalieva"
    Project = "Terraform with AWS"
  }*/
}
resource "aws_instance" "server" { #EC2 INSTANCE 
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.myDYNAMICSG.id] #REFERENCE TO NEW CREATED SG
  monitoring             = var.detailed_monitoring
}
resource "aws_security_group" "myDYNAMICSG" { #DYNAMIC SG WITH BLOCK CODES
  name = "DynamicSG"
  dynamic "ingress" {
    for_each = var.allow_ports #BLOCK CODE
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "Server SG"
    Owner   = "Akmaanai Zhumalieva"
    Project = "Terraform with AWS"
  }
}


#----------------------------------VPC VARIABLE CUSTOMIZING-----------------
module "vpc" {
   source  = "terraform-aws-modules/vpc/aws"
   version = "2.44.0"

   cidr = "10.0.0.0/16"

   azs             = data.aws_availability_zones.available.names
-  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
-  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
+  private_subnets = slice(var.private_subnet_cidr_blocks, 0, var.private_subnet_count)   #SLICE IS COMBANING 2 VARIABLES, START INDEX AND END INDEX
+  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, var.public_subnet_count)
   ## ...
 }
