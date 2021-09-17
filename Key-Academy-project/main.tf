provider "aws" {
  region = var.region
}
terraform {
  backend "s3" {
    bucket = "for-remote-state-terraform-aku"
    key = "prod-devops/terraform.tfstate"
    region = "eu-west-3"
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

#-------------------------------------------------------------------------------------------------------
module "vpc-dev" {
  source              = "./modules/vpc"
  env                 = var.env
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
}
/*module "vpc-prod" {
  source               = "./modules/vpc"
  env                  = "Prods"
  vpc_cidr             = "10.100.0.0/16"
  public_subnet_cidrs  = ["10.100.1.0/24", "10.100.2.0/24"]
  private_subnet_cidrs = []
}*/

module "my_ec2" {
  source                 = "./modules/ec2"
  ami_id                 = data.aws_ami.latest_version.id
  subnet_id              = module.vpc-dev.public_subnet_ids[0]
  vpc_security_group_ids = ["${module.vpc-dev.security_group_id}"]
}
resource "aws_eip" "ipaddress" {
  // vpc = true
  count    = length(module.my_ec2.ec2_instance_ids)
  instance = element(module.my_ec2.ec2_instance_ids, count.index)

  tags = {
    "Name"  = "Web-Server-EIP-${terraform.workspace}-${count.index + 1}"
    "Owner" = "Akmaanai"
  }
}
resource "aws_instance" "example" {   # #set the instance type to t2.medium in the default workspace and t2.micro in all other WORKSPACES
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = (
    terraform.workspace == "default" 
    ? "t2.medium" 
    : "t2.micro"
  )
}