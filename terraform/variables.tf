variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "ID of the AMI to provision. Default is Ubuntu 18.04 LTS" // https://cloud-images.ubuntu.com/locator/ec2
  default     = "ami-079f96ce4a4a7e1c7"
}

variable "count" {
  description = "How many servers to provision"
  default     = 1
}

variable "instance_type" {
  description = "type of EC2 instance to provision."
  default     = "t2.micro"
}

variable "name" {
  description = "name to pass to Name tag"
  default     = "jray-ptfe-jenkins"
}

variable "owner" {
  description = "jray@hashicorp.com"
}

variable "key_name" {
  description = "jray"
}

variable "ttl" {
  description = "A desired time to live (not enforced via terraform)"
  default     = "-1"
}

variable "user_data" {
  description = "A user data script"
  default     = "./user-data/user_data.sh"

  # default     = "cd /tmp && echo \"Provisioned by Terraform\" > user_data.txt"
}

variable subnet_id {
  description = "default subnet for EC2 instance within specified VPC"
  default     = "subnet-055c621fd6b3df116"
}

variable "security_group_id" {
  type    = "list"
  default = ["sg-08dc78d1f405f6f4d"]
}