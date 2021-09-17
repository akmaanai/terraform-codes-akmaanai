
# Provision:
#  - VPC,Security Group, Autoscaling Group, Elastic Load Balancer
#  - Internet Gateway
#  - XX Public Subnets
#  - XX Private Subnets
#  - XX NAT Gateways in Public Subnets to give access to Internet from Private Subnets

#--------------------------------------------------------------------------------
provider "aws" {
  region = "eu-west-3"
}

data "aws_availability_zones" "available" {}
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}
#---------------VPC AND INTERNET GATEWAY---------------------------------------------

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-IGW"
  }
}

#-------------PUBLIC SUBNETS AND ROUTING------------------------------------------------

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-Public-${count.index + 1}"
  }
}
resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}-route-public-subnet"
  }
}

resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
}

#-------------NAT GATEWAYS WITH ELASTIC IPs-----------------------------------------------


resource "aws_eip" "nat" {
  count = length(var.private_subnet_cidrs)
  vpc   = true
  tags = {
    Name = "${var.env}-EIP-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)
  tags = {
    Name = "${var.env}-NAT-GW-${count.index + 1}"
  }
}

#--------------PRIVATE SUBNETS AND ROUTING-------------------------------------------------

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.env}-Private-${count.index + 1}"
  }
}

resource "aws_route_table" "private_subnets" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = {
    Name = "${var.env}-route-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_routes" {
  count          = length(aws_subnet.private_subnets[*].id)
  route_table_id = aws_route_table.private_subnets[count.index].id
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
}

#------------------------SECURITY GROUP-----------------------------------------------------
resource "aws_security_group" "mySG" { #DYNAMIC SG WITH BLOCK CODES
  name   = "DevopsSG"
  vpc_id = aws_vpc.main.id
  dynamic "ingress" {
    for_each = ["80", "443", "22"] #BLOCK CODE
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

#-------------------AUTO SCALING GROUP AND LAUCH CONFIGURATION--------------------------------
resource "aws_launch_configuration" "launch_conf" { #LAUNCH CONFIGURATION
  /* name            = "web_config"*/
  name_prefix     = "Devops-Web-Config-" #NAME PREFIX IS FOR AVOIDING NAME CONFLICTS IN REDEPLOYMENT
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.mySG.id]
  user_data       = file("script.sh")
  key_name        = "aws_key_pair.devops.id"
}

/*resource "aws_key_pair" "devops" {
  key_name   = "terra"
  public_key = "hbnfgh:Klkhjb)^%hgjkhkljkljSdfgv"
}*/
resource "aws_autoscaling_group" "HA-Web" {
  name                 = "Devops-ASG-${aws_launch_configuration.launch_conf.name}" #ADDING TO SUFFIX A RESOURCE PREFIX
  launch_configuration = aws_launch_configuration.launch_conf.name
  min_size             = 2
  max_size             = 3
  min_elb_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.ELB.name]

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "HA-Web-Private" {
  name                 = "Devops-Private-ASG-${aws_launch_configuration.launch_conf.name}" #ADDING TO SUFFIX A RESOURCE PREFIX
  launch_configuration = aws_launch_configuration.launch_conf.name
  min_size             = 2
  max_size             = 3
  min_elb_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.ELB.name]

  lifecycle {
    create_before_destroy = true
  }
}

#----------------------ELASTIC LOAD BALANCER---------------------------------------------------
resource "aws_elb" "ELB" {
  name = "Devops-ALB"
  //load_balancer_type = "application"
  security_groups = [aws_security_group.mySG.id]
  subnets         = aws_subnet.public_subnets.*.id
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
}
#----------------------------------------------------------------------------------------------

