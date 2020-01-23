provider "aws" {
  region = "${var.aws_region}"
}

//--------------------------------------------------------------------
// Variables
variable "cidr_ingress" {
  description = "VPC CIDR blocks incoming traffic"
  type        = "list"
  default     = ["0.0.0.0/16"]
}
variable "instance_count" {
  description = "Number of instances to build"
  default = 1
}
variable "subnetid" {
  description = "Subnet ID (default = subnet_public_ids[0]"
  default = ""
}
variable "public" {
  description = "Instance is accessibly from outside (default: true)"
  default     = true
}
variable "instance_type" {
  description = "Select Instance Size (default: t2.micro)"
  type        = "string"
  default     = "t2.micro"
}

//--------------------------------------------------------------------
// Modules

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.17.0"
  //source  = "app.terraform.io/presto-workshop-tfc-aws/vpc/aws"
  //version = "2.21.0"

  name = "presto-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "presto-dev"
  }
}

#data "aws_security_group" "default" {
#  name   = "default"
#  vpc_id = "${module.vpc.vpc_id}"
#}

resource "aws_security_group" "myapp" {
  name_prefix = "${var.name_prefix}-myapp-"
  description = "Security Group for ${var.name_prefix} Web App"
  vpc_id      = "${module.vpc.default_vpc_id}"

  #tags = "${map("Name", format("%s-myapp", var.name_prefix))}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = "${var.cidr_ingress}"
  }

  tags = {
    Name = "allow_all"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "main" {
  count                       = "${var.instance_count != "" ? var.instance_count : 0}"
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.instance_type}"
  associate_public_ip_address = "${var.public}"
  vpc_security_group_ids      = "${[aws_security_group.myapp.id]}"
  subnet_id                   = "${module.vpc.public_subnets[0]}"
  
  tags = {
    Name  = "${var.name_prefix}_${count.index+1}"
    owner = "ppresto@hashicorp.com"
    TTL   = 24
  }
}