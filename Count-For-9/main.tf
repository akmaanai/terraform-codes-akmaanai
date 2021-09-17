provider "aws" {
  region = "us-east-1"
}
variable "user_names" {
  default = ["dev1", "dev2", "dev34", "dev45"]
}
resource "aws_iam_user" "users" {
  count = length(var.user_names)
  name  = element(var.user_names, count.index)
}

resource "aws_instance" "servers" {
  ami = "ami-087c17d1fe0178315"
  instance_type = "t2.micro"
  count = 3
  tags = {
    "Name" = "SERVER - ${count.index +1}"                      # +1 means will start from 1, not 0
  }
}
#-------------------------------------------------------------------------------------------------------------------------

output "created_iam_users" {
  value = aws_iam_user.users[*].name
}
output "created_iam_users_arn" {                                 #PRINT USER NAMES WITH ARN
  value = [
      for user in aws_iam_user.users:
      "Username: ${user.name} has ARN: ${user.arn}"
  ]
}

output "custom_if_lenght" {
  value = [
      for x in aws_iam_user.users :                               #PRINT USER NAMES WITH ONLY 4 CHARACTERS
      x.name
      if length(x.name) == 4
  ]
}
output "server_all" {                                             #PRINT NICE MAP OF INSTANCE ID AND PUBLIC IP
  value = {
      for server in aws_instance.servers :
      server.id => server.public_ip
  }
}