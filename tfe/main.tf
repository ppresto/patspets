//--------------------------------------------------------------------
// Modules
module "aws_std_network" {
  source  = "app.terraform.io/Patrick/aws_std_network/aws"
  version = "0.2.3"
  name_prefix = "0913-ppresto-dev-network"
}

module "ec2_instance" {
  source  = "app.terraform.io/Patrick/ec2_instance/aws"
  version = "0.1.6"

  name_prefix = "0913-ppresto-dev"
  securitygroup_id = "${module.aws_std_network.webapp_security_group}"
}
//--------------------------------------------------------------------
// OUTPUTS - For Useability
output "private_key_filename" {
  value = "${module.ec2_instance.private_key_filename}"
}
output "private_key_pem" {
  value = "${module.ec2_instance.private_key_pem}"
}
output "my_nodes_public_ips" {
  value = "${module.ec2_instance.my_nodes_public_ips}"
}
output "my_bastion_public_ips" {
  value = "${module.ec2_instance.my_bastion_public_ips}"
}