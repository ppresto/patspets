//--------------------------------------------------------------------
// Modules
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = "${module.vpc.vpc_id}"
}

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
  count                       = 1
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = "${module.vpc.default_security_group_id}"
  subnet_id                   = "${module.vpc.public_subnets[0]}"
  
  tags = {
    Name  = "${var.name_prefix}_${count.index+1}"
    owner = "ppresto@hashicorp.com"
    TTL   = 24
  }
}

//--------------------------------------------------------------------
// OUTPUTS - For Useability