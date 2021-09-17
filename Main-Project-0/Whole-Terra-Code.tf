provider "aws" {
  region     = "us-east-1"
}
resource "aws_instance" "webserver" { #EC2 INSTANCE WITH BOOTSTRAP & SG
  ami           = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"
  /*vpc_id = "${aws_vpc.myVPC.id}"8*/
  vpc_security_group_ids = [aws_security_group.myDYNAMICSG.id] #REFERENCE TO NEW CREATED SG
  /*user_data              = file("./outfiles/script")    */   #LINK to the BOOTSTRAP-STATIC FILE
  user_data = templatefile("dynam.sh.tpl", {                   #LINK to the BOOTSTRAP-DYNAMIC FILE WITH 
    f_name = "Akmaanai"                                        #VARIABLES
    l_name = "Zhumalieva"
    names  = ["Nurzada", "Nuriza", "Tynchtyk", "Talant"] #ARRAY
  })
  tags = {
    "Name"  = "Webserver-guru"
    "Owner" = "Akmaanai"
  }
  /*lifecycle {
    prevent_destroy = true
  }*/
}

resource "aws_eip" "ipaddress" {                               #ELASTIC IP ADDRESS that REFERENCED TO NEW CREATED EC2
  instance = aws_instance.webserver.id

}

/*resource "aws_security_group" "mySG" {                       #USUAL SG
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

}*/

resource "aws_security_group" "myDYNAMICSG" { #DYNAMIC SG WITH BLOCK CODES
  name = "DynamicSG"
  dynamic "ingress" {
    for_each = ["80", "443", "8080", "22"] #BLOCK CODE
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    lifecycle {
      ignore_changes = [ ingress ]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_iam_user" "users" {
  count = length(var.user_names)
  name  = element(var.user_names, count.index)
}

/*resource "aws_vpc" "myVPC" {                                 #VPC
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "DevopsVPC"
  }
}

resource "aws_subnet" "mysubnet1" {                          #SUBNET
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"
  tags = {
    "Name" = "DevopsSubnet1"
  }
  depends_on = [aws_eip]                                     #FIRST CREATE EIP THEN SUBNET, DEPENDICIES AND REFERENCES
}*/

/*lifecycle {                                                  #USE ALMOST FOR EVERY RESOURCES
  prevent_destroy = true                                    #PREVENT FROM DESTROYING
  ignore_changes = [ ingress, ami, user_data ]              #PREVENT FROM CHANGING 
  create_before_destroy = true                              #FIRST CREAT THEN DESTROY, MINIMIZE DOWNTIME 
  }*/

output "webserver_instance_id" { #GIVES THE RESULTS IF YOU HAVE NO ACCESS TO CONSOLE
  value = aws_instance.webserver.id
}
output "webserver_public_ip_address" { #IT IS BETTER TO KEEP OUTPUTS IN DIFFERENT FILE
  value = aws_eip.ipaddress.public_ip
}
output "webserver_SG_id" { #RUN terraform show TO KNOW ALL THE OUTPUTS
  value = aws_security_group.myDYNAMICSG.id
}
output "all_arns" {
  value       = aws_iam_user.users[*].arn
  description = "The ARNs for all users"
}
