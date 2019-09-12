//--------------------------------------------------------------------
// Module - GCP Instances
module "gce_instance" {
  source  = "app.terraform.io/Patrick/gce_instance/google"
  version = "0.1.4"
  name_prefix = "${replace(var.name_prefix,"/_/","-")}"  #replace _ to meet GCE naming requirements
  count = 0
  machine_type = "n1-standard-2"
}

output "GCP_Address" {
  value = "${module.gce_instance.addresses}"
}

//--------------------------------------------------------------------
// Module - AWS Instances
module "ec2_instance" {
  source  = "app.terraform.io/Patrick/ec2_instance/aws"
  version = "0.1.5"
  name_prefix = "${var.name_prefix}"
  count = 0
  instance_type = "t2.micro"
  subnet_id = "${data.terraform_remote_state.patrick_tf_aws_standard_network.subnet_private_ids[0]}"
}

//--------------------------------------------------------------------
// AWS Network - Get Network Team's Existing VPC Data from their Workspace
data "terraform_remote_state" "patrick_tf_aws_standard_network" {
  backend = "atlas"
  config {
    address = "https://app.terraform.io"
    name    = "Patrick/tf-aws-standard-network"
  }
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