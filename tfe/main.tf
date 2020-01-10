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
  version = "2.0.6"
  name_prefix = "${var.name_prefix}"
  instance_count = 5
  instance_type = "t3.large"
  security_group = "${data.terraform_remote_state.patrick_tf_aws_standard_network.outputs.security_group_web}"
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
