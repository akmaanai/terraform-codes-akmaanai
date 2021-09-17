provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "for-remote-state-terra"
    key    = "devops/prod/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform_locks"
    encrypt        = true
  }
}
#--------------------------------------------------------------------------------
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "env" {
  default = "dev"
}
variable "public_subnet_cidrs" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}
#---------------------------------------------------------------------------------
data "aws_availability_zones" "available" {}

resource "aws_s3_bucket" "for-remote-state-terra" {                                       #CREATE S3 BUCKET FOR REMOTE STATE WITH SERVER SIDE ENCRYPTION
  bucket = "terraform-up-and-running-state"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {        #To use DynamoDB for locking with Terraform, you must create a DynamoDB table that has a primary key called LockID 
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_vpc" "vpc-main" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "main_IG" {
  vpc_id = aws_vpc.vpc-main.id
  tags = {
    "Name" = "${var.env}-igw"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc-main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-${count.index + 1}"
  }
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.vpc-main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_IG.id
  }
  tags = {
    Name = "${var.env}-route-public-subnets"
  }
}
resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
}


output "s3_bucket_arn" {
  value       = aws_s3_bucket.for-remote-state-terra.arn
  description = "The ARN of the S3 bucket"
}
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"

output "vpc_id" {
  value = aws_vpc.vpc-main.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc-main.cidr_block
}
output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}