provider "aws" {
  region = "us-east-1"
}
/*resource "aws_instance" "web" {
  ami                    = "ami-0c2b8ca1dad447f8a"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mySG.id]
  user_data              = templatefile("dynam.sh.tpl", {
      f_name = "Akmaanai"
      l_name = "Zhumalieva"
      names = [ "Nurzada", "Nuriza", "Tynchtyk", "Talant"]
  })
  tags = {
    "Name"  = "Webserver"
    "Owner" = "Akmaanai"
  }
}*/
/*resource "aws_eip" "ipaddress" {
  instance = "${aws_instance.web.id}"
  
}*/
resource "aws_security_group" "mySG" {
  name = "DynamicSG"
  dynamic "ingress" {
    for_each = ["80", "443", "8080", "53", "9093"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
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