
//--------------------------------------------------------------------
// Modules
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "myapp_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
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

module "ec2_cluster" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "my-cluster"
  instance_count         = 3

  ami                    = "ami-04590e7389a6e577c"
  instance_type          = "t2.micro"
  key_name               = "ppresto-ptfe-dev-key"
  monitoring             = true
  vpc_security_group_ids = [module.myapp_sg.this_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "ppresto-dev"
  }
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "public_subnets" {
  value = "${module.vpc.public_subnets}"
}

output "default_security_group_id" {
  value = "${module.vpc.default_security_group_id}"
}

output "availability_zone" {
  value = "${module.ec2_cluster.availability_zone}"
}

output "ec2_ids" {
  value = "${module.ec2_cluster.id}"
}

output "key_name" {
  value = "${module.ec2_cluster.key_name}"
}

output "subnet_id" {
  value = "${module.ec2_cluster.subnet_id}"
}

output "ec2_security_group_ids" {
  value = "${module.ec2_cluster.vpc_security_group_ids}"
}

output "web_security_group_ids" {
  value = "${module.myapp_sg.this_security_group_id}"
}
