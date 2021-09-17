output "lb_url" {
  description = "URL of load balancer"
  value       = "http://${module.elb_http.this_elb_dns_name}/"
}
output "vpc_id" {
  description = "ID of project VPC"
  value       = module.vpc.vpc_id
}
output "web_server_count" {
  description = "Number of web servers provisioned"
  value       = length(module.ec2_instances.instance_ids)
}

#Outputs: use the "terraform output" command to query all of them.
lb_url = "http://lb-5YI-project-alpha-dev-2144336064.us-east-1.elb.amazonaws.com/"
vpc_id = "vpc-004c2d1ba7394b3d6"
web_server_count = 4

output "db_password" {
  description = "Database administrator password"
  value       = aws_db_instance.database.password
  sensitive   = true                                          #will not display the password, use "terraform output" to display
}
# "terraform output -json" will display outputs in machine readable language