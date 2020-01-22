//--------------------------------------------------------------------
// Modules
module "aws_std_network" {
  name = "${var.name_prefix}"
  source  = "app.terraform.io/Patrick/aws_std_network/aws"
  version = "0.2.4"
}

module "ec2_instance" {
  source  = "app.terraform.io/Patrick/ec2_instance/aws"
  version = "2.0.7"

  name_prefix = "${var.name_prefix}"
  instance_count = 5
  instance_type = "t2.nano"
  security_group = "${module.aws_std_network.security_group_web}"
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