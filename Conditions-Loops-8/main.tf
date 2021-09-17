provider "aws" {
  region = "us-east-1"
}

variable "env" {                                  #ENVIROMENT VARIABLE FOR CONDITIONS
  default = "dev"
}
variable "prod_owner" {
  default = "Akmaanai Zhumalieva"
}
variable "another" {
  default = "Not me, someone"
}

variable "ec2_size" {
  default = {
    "prod" = "t3.medium"
    "dev" = "t3.micro"
    "staging" = "t2.small"
  }
}

variable "allow_port_list" {
  default = {
    "prod" = ["80", "443"]
    "dev" = ["80", "443", "22", "8080"]
  }
}
#--------------------------------------------------------------------
resource "aws_instance" "Prod_Server1" {
  ami = "ami-087c17d1fe0178315"
  /*instance_type = (var.env == "prod" ? "t3.micro" : "t2.micro")  */   #IF VALUE IS PROD USE t3.micro, IF ANOTHER VALUES USE t2.micro
    instance_type = var.env == "prod" ? var.ec2_size["prod"] : var.ec2_size["dev"]
  tags = {
      Name = var.env == "dev" ? "dev" : var.env == "prod" ? "prod" : "undefined" 
      //Name = "${var.env}-server"
      Owner = (var.env == "prod" ? var.prod_owner : var.another)
  }
}

resource "aws_instance" "Prod_Server2" {
  ami = "ami-087c17d1fe0178315"
  instance_type = lookup(var.ec2_size, var.env)     #IF VA
  tags = {
      Name = "${var.env}-server"
      Owner = (var.env == "prod" ? var.prod_owner : var.another)
  }
}

resource "aws_instance" "Dev_Server" {
  count = (var.env == "dev" ? 1 : 0) 
  ami = "ami-087c17d1fe0178315"
  instance_type = "t2.micro"
  tags = {
      Name = "Dev-Bastion-Server"
  }
}

#--------------------------------------------------------------------------------------
resource "aws_security_group" "mySG" {
  name = "DynamicSG"
  dynamic "ingress" {
    /* for_each = ["80", "443", "8080", "53", "22"] */
    for_each = lookup(var.allow_port_list, var.env)
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
}