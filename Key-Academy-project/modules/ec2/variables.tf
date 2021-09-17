variable "ec2_count" {
  default = "2"
}
variable "ami_id" {
}
variable "instance_type" {
  default = "t2.micro"
}
variable "subnet_id" {
}
variable "env" {
  default = "Devops"
}
variable "vpc_security_group_ids" {
}
locals {
  user_data = <<EOF
  #!/bin/bash
        sudo yum -y update
		sudo yum install -y httpd
		sudo systemctl start httpd
		sudo systemctl enable httpd
		echo "<h1>Deployed via Terraform. Good job Akumonya)</h1>" | sudo tee /var/www/html/index.html
    EOF

    tags = {
      "Name" = "Devops-Server"
      "Owner" = "Akumonya"
    }
}
