resource "aws_instance" "web" {
  count = var.ec2_count
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  user_data = local.user_data
  tags = {
     "Name" = "Devops-Server-${terraform.workspace}-${count.index + 1}"
  }
}