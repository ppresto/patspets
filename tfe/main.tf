//--------------------------------------------------------------------
// Module - GCP Instances
module "gce_instance" {
  source  = "app.terraform.io/Patrick/gce_instance/google"
  version = "0.1.4"
  name_prefix = "ppresto-cicd-gce-node"
}

output "GCP_Address" {
  value = "${module.gce_instance.addresses}"
}
