//--------------------------------------------------------------------
// Modules
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source  = "app.terraform.io/presto-workshop-tfc-aws/vpc/aws"
  version = "2.21.0"

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

module "ec2_instance" {
  source  = "app.terraform.io/Patrick/ec2_instance/aws"
  version = "2.0.7"

  name_prefix = "${var.name_prefix}"
  instance_count = 5
  instance_type = "t2.nano"
  security_group = "${module.vpc.default_security_group_id}"
}

//--------------------------------------------------------------------
// OUTPUTS - For Useability

output "private_key_pem" {
  value = "${module.ec2_instance.private_key_pem}"
}
output "my_nodes_public_ips" {
  value = "${module.ec2_instance.my_nodes_public_ips}"
}
output "my_bastion_public_ips" {
  value = "${module.ec2_instance.my_bastion_public_ips}"
}