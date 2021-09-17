
output "vpc_id" {
  value = module.vpc-dev.vpc_id
}
output "vpc_public_subnets" {
  value = module.vpc-dev.public_subnet_ids
}
output "security_group" {
  value = module.vpc-dev.security_group_id
}
output "ec2_instances" {
  value = module.my_ec2.ec2_instance_ids
}
output "elastic_ips" {
  value = aws_eip.ipaddress[*].id
}