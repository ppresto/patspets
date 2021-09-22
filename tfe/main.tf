//--------------------------------------------------------------------
// Workspace Data
data "terraform_remote_state" "vpc" {
  backend = "remote"
  config  = {
    hostname = "app.terraform.io"
    organization = var.organization
    workspaces = {
      name    = "tf-aws-standard-network"
    }
  }
}

//--------------------------------------------------------------------
// Modules
module "ec2_instance" {
  source  = "app.terraform.io/Patrick/ec2_instance/aws"
  version = "2.0.9"    //verify policy: use-latest-module-version
  //version = "2.0.10"
  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnets[0]
  name_prefix = var.prefix
  tags = var.tags
  instance_count = 1
  instance_type = "t2.nano"
  security_group = data.terraform_remote_state.vpc.outputs.security_group_web
}



//--------------------------------------------------------------------
// OUTPUTS - For Useability

output "private_key_pem" {
  value = "${module.ec2_instance.private_key_pem}"
  sensitive = true
}
output "my_nodes_public_ips" {
  value = "${module.ec2_instance.my_nodes_public_ips}"
}
