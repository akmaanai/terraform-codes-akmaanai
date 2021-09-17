provider "aws" {
  region = "us-east-1"
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
#-------------------------------------------------------------------

resource "aws_security_group" "mySG" {                                    #DYNAMIC SG WITH BLOCK CODES
  name = "DynamicSG"
  dynamic "ingress" {
    for_each = ["80", "443"]                                              #BLOCK CODE
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

#----------------------------------------------------------------------
resource "aws_launch_configuration" "launch_conf" {                       #LAUNCH CONFIGURATION
 /* name            = "web_config"*/
  name_prefix     = "web-config-"                                         #NAME PREFIX IS FOR AVOIDING NAME CONFLICTS IN REDEPLOYMENT
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.mySG.id]
  user_data       = file("script.sh")
  lifecycle {
    create_before_destroy = true
  }
}
#----------------------------------------------------------------------
resource "aws_autoscaling_group" "HA-Web" {                               #AUTOSCALING GROUP
  name                 = "ASG-${aws_launch_configuration.launch_conf.name}"  #ADDING TO SUFFIX A RESOURCE PREFIX
  launch_configuration = aws_launch_configuration.launch_conf.name
  min_size             = 2
  max_size             = 3
  min_elb_capacity     = 2
  vpc_zone_identifier  = [aws_default_subnet.df-az1.id, aws_default_subnet.df-az2.id]
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.ELB.name]

  lifecycle {
    create_before_destroy = true
  }
}
#---------------------------------------------------------------------

resource "aws_elb" "ELB" {
  name               = "HA-ELB-Server"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.mySG.id]
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
#-------------------------------------------------------------------------------

resource "aws_default_subnet" "df-az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}
resource "aws_default_subnet" "df-az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

output "web_loadbalancer_url" {
  value = aws_elb.ALB.dns_name
}
 