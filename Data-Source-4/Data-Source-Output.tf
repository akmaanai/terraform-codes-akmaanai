provider "aws" {
  region = "us-east-1"
}
#--------------------------------------------------------------------------------------------------------
data "aws_ami" "latest_version" {                     #INFORMATION ABOUT LATEST VERSION OF AMI
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}
output "latest_version_name" {                        #OUTPUT IN THE TERMINAL - NAME OF AMI
  value = data.aws_ami.latest_version.name
}
output "latest_version_id" {                          #OUTPUT IN THE TERMINAL - ID OF AMI
  value = data.aws_ami.latest_version.id
}
#----------------------------------------------------------------------------------------------------------

data "aws_availability_zones" "working" {}            #INFORMATION ABOUT AZ IN THE WORKING REGION

output "data_aws_availability_zones" {
  value = data.aws_availability_zones.working.names   #OUTPUT IN THE TERMINAL - LIST OF AZ IN THE REGION
}
#----------------------------------------------------------------------------------------------------------

data "aws_caller_identity" "current1" {}              #INFORMATION ABOUT THE ID NUMBER OF USER

output "data_aws_caller_identity" {                   #OUTPUT IN THE TERMINAL - ID NUMBER OF ACCOUNT
  value = data.aws_caller_identity.current1.account_id
}
#----------------------------------------------------------------------------------------------------------

data "aws_region" "current2" {}                      #INFORMATION ABOUT THE REGION

output "data_aws_region" {                           #OUTPUT IN THE TERMINAL - NAME OF THE REGION
  value = data.aws_region.current2.name
}
output "data_aws_region_describe" {                  #OUTPUT IN THE TERMINAL - DESCRIPTION OF THE REGION
  value = data.aws_region.current2.description
}
#----------------------------------------------------------------------------------------------------------

data "aws_vpc" "vpc-aku" {                           #INFORMATION ABOUT CUSTOM VPC
    tags = {
      "Name" = "DevopsVPC"                           #FIND THE CUSTOM VPC BY THE NAME
    }
    depends_on = [                                   #FIRST CREATE THE VPC AND FIND THIS VPC - DEPENDICIES
      aws_vpc.myVPC
    ]
}
output "data_aws_vpc" {                              #OUTPUT IN THE TERMINAL - ID OF THE VPC
  value = data.aws_vpc.vpc-aku.id
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "myVPC" {                         #CREATE VPC
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "DevopsVPC"
  }
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "mysubnet1" {                                                        #CREATE SUBNET IN CUSTOM VPC
  vpc_id     = data.aws_vpc.vpc-aku.id
  availability_zone = data.aws_availability_zones.working.names[0]                         #REFERENCE TO DATA - AZ NAME - FIRST AZ
  cidr_block = "10.0.1.0/24"
  tags = {
    "Name" = "DevopsSubnet1 in ${data.aws_availability_zones.working.names[0]}"            #REFERENCE TO DATA - AZ NAME
    "Account" = "DevopsSubnet1 in ${data.aws_caller_identity.current1.account_id}"         #REFERENCE TO DATA - ACCOUNT ID
    "Region" =  data.aws_region.current2.description                                       #REFERENCE TO DATA - REGION DESCRIPTION
  }
}

resource "aws_subnet" "mysubnet2" {                                                        #CREATE SUBNET IN CUSTOM VPC
  vpc_id     = data.aws_vpc.vpc-aku.id
  availability_zone = data.aws_availability_zones.working.names[1]                         #REFERENCE TO DATA - AZ NAME - SECOND AZ
  cidr_block = "10.0.2.0/24"
  tags = {
    "Name" = "DevopsSubnet2 in ${data.aws_availability_zones.working.names[1]}"            #REFERENCE TO DATA - AZ NAME
    "Account" = "DevopsSubnet2 in ${data.aws_caller_identity.current1.account_id}"         #REFERENCE TO DATA - ACCOUNT ID
    "Region" =  data.aws_region.current2.description                                       #REFERENCE TO DATA - REGION DESCRIPTION
  } 
}                                  
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

data "aws_region" "current" { }
output "aws_region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}
