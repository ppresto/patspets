//--------------------------------------------------------------------
// Workspace Data
data "terraform_remote_state" "patrick_tf_aws_standard_network" {
  backend = "atlas"
  config  = {
    address = "https://app.terraform.io"
    name    = "${var.organization}/tf-aws-standard-network"
    #name    = "Patrick/tf-aws-standard-network"
  }
}

locals {
  # Use a standard naming convention to map Workspaces to Teams
  url = "app.terraform.io/${var.organization}/ec2_instance/aws"
}

//--------------------------------------------------------------------
// Modules
module "ec2_instance" {
  #source  = "app.terraform.io/Patrick/ec2_instance/aws"
  source  = "${local.url}"

  // version - Use 2.0.6/2.0.7 to test policy: use-latest-module-version
  version = "2.0.8"
  name_prefix = "${var.name_prefix}"
  instance_count = 5
  instance_type = "t2.nano"
  security_group = "${data.terraform_remote_state.patrick_tf_aws_standard_network.outputs.security_group_web}"
  tags = {
    Environment = "dev"
    owner       = "uswest-se-ppresto"
    TTL         = 24
  }
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