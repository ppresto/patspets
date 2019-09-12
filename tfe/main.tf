//--------------------------------------------------------------------
// Module - GCP Instances
module "gce_instance" {
  source  = "app.terraform.io/Patrick/gce_instance/google"
  version = "0.1.4"
  name_prefix = "${var.name_prefix}"
  count = 1
}

output "GCP_Address" {
  value = "${module.gce_instance.addresses}"
}
