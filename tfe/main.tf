//--------------------------------------------------------------------
// Module - GCP Instances
module "gce_instance" {
  source  = "app.terraform.io/Patrick/gce_instance/google"
  version = "0.1.4"
  name_prefix = "${replace(var.name_prefix,"/_/","-")}"  #replace _ to meet GCE naming requirements
  count = 2
  machine_type = "n1-standard-8"
}

output "GCP_Address" {
  value = "${module.gce_instance.addresses}"
}