provider "aws" {
  region = "us-east-1"
}
provider "aws" {
  region = "ap-northeast-1"
  alias  = "Tokyo"
}
provider "aws" {
  region = "eu-west-3"
  alias  = "Paris"
}
#------------------------------------------------------------------------------

resource "aws_instance" "Server-USA" {
  ami           = "ami-087c17d1fe0178315"
  instance_type = "t3.micro"
  tags = {
    "Name" = "Server-USA"
  }
}

resource "aws_instance" "Server-Tokyo" {
  provider      = aws.Tokyo
  ami           = "ami-02892a4ea9bfa2192"
  instance_type = "t3.micro"
  tags = {
    "Name" = "Server-Tokyo"
  }
}

resource "aws_instance" "Server-Paris" {
  provider      = aws.Paris
  ami           = "ami-072056ff9d3689e7b"
  instance_type = "t3.micro"
  tags = {
    "Name" = "Server-Paris"
  }
}