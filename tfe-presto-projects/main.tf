//--------------------------------------------------------------------
// Workspace Data
data "terraform_remote_state" "presto_projects_aws_std_network" {
  backend = "atlas"
  config = {
    address = "https://app.terraform.io"
    name    = "presto-projects/aws-std-network"
  }
}

//--------------------------------------------------------------------
// Modules
module "ec2_instance" {
  source  = "app.terraform.io/presto-projects/ec2-instance/aws"
  // version - Use 2.0.6/2.0.7 to test policy: use-latest-module-version
  version = "2.0.8"
  tfe_org = "presto-projects"
  tfe_workspace = "aws-std-network"
  name_prefix = "${var.name_prefix}"
  instance_count = 5
  instance_type = "t2.nano"
  security_group = "${data.terraform_remote_state.presto_projects_aws_std_network.outputs.security_group_web}"
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