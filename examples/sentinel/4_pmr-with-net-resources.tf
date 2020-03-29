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
  version = "2.0.7"

  name_prefix = "${var.name_prefix}"
  security_group = "${aws_security_group.myapp.id}"
  //security_group = "${data.terraform_remote_state.patrick_tf_aws_standard_network.outputs.security_group_web}"

  instance_count = 5
  instance_type = "t2.nano"
    tags = {
    Environment = "dev"
    owner       = "uswest-se-ppresto"
    TTL         = 24
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
  default     = ["157.131.174.226/32"]
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