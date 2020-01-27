
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.17.0"
  //source  = "app.terraform.io/presto-workshop-tfc-aws/vpc/aws"
  //version = "2.21.0"

  name = "presto-vpc"
  cidr = "10.10.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets  = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Environment = "presto-dev"
  }
}

module "myapp_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "myapp-service"
  description = "Security group for myapp-service with my custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["10.10.0.0/16"]
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "myapp-service ports"
      cidr_blocks = "10.10.0.0/16"
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

//--------------------------------------------------------------------
// Workspace Data
data "terraform_remote_state" "patrick_tf_aws_standard_network" {
  backend = "atlas"
  config  = {
    address = "https://app.terraform.io"
    name    = "Patrick/tf-aws-standard-network"
  }
}

//--------------------------------------------------------------------
// Modules
module "ec2_instance" {
  source  = "app.terraform.io/Patrick/ec2_instance/aws"
  // version - Change version to pass policy: use-latest-module-version
  version = "2.0.7"
  name_prefix = "${var.name_prefix}"
  instance_count = 5
  instance_type = "t2.large"
  security_group = "${aws_security_group.myapp.id}"
  //security_group = "${data.terraform_remote_state.patrick_tf_aws_standard_network.outputs.security_group_web}"
  tags = {
    Environment = "dev"
    #owner       = "uswest-se-ppresto"
    #TTL         = 24
  }
}

resource "aws_security_group" "myapp" {
  name_prefix = "${var.name_prefix}-myapp-"
  description = "Security Group for ${var.name_prefix} Web App"
  vpc_id      = "${data.terraform_remote_state.patrick_tf_aws_standard_network.outputs.vpc_id}"

  tags = "${map("Name", format("%s-myapp", var.name_prefix))}"
}

resource "aws_security_group_rule" "egress_web" {
  security_group_id = "${aws_security_group.myapp.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = var.cidr_ingress
}

resource "aws_security_group_rule" "web-8080" {
  security_group_id = "${aws_security_group.myapp.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 8080
  to_port           = 8080
  cidr_blocks       = var.cidr_ingress
}

variable "cidr_ingress" {
  description = "VPC CIDR blocks incoming traffic"
  type        = "list"
  default     = ["0.0.0.0/0"]
  #default     = ["157.131.174.226/32"]
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