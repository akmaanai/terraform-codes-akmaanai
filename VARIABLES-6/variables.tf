variable "region" {
  description = "Enter region name to deploy Server"
  default     = "us-east-1"
}
variable "instance_type" {
  description = "Enter Instance type"
  default     = "t2.micro"
}
variable "allow_ports" {
  type    = list(any)
  default = ["80", "443", "22", "8080"]
}
variable "detailed_monitoring" {
  description = "Enable detailed monitoring for extra money? True or False"
  type = bool                                 #IN APPLY WILL ASK TRUE OR FALSE
  /*default = "false"*/
}
variable "common_tags" {
    description = "Common tags to apply to all resources"
    type = map
    default = {
        Owner = "Akmaanai Zhumalieva"
        Project = "Terraform with AWS"
        Enviroment = "Devops"
    }
}

/* terraform apply -var="region=ca-central-1" -var="instance_type=t2.micro" */ #Changing 2 variable values in input while applying





#----------------------------------VPC VARIABLE CUSTOMIZING----------------------------------------------

variable "public_subnet_count" {
  description = "Number of public subnets."
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets."
  type        = number
  default     = 2
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets."
  type        = list(string)
  default     = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24",
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets."
  type        = list(string)
  default     = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24",
  ]
}

#-------------------Interpolate variables in strings----------------
-  name        = "web-sg-project-alpha-dev"
+  name        = "web-sg-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"

-  name        = "lb-sg-project-alpha-dev"
+  name        = "lb-sg-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"