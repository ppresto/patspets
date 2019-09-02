//--------------------------------------------------------------------
// Modules
module "aws_instance" {
  source             = "app.terraform.io/Patrick/aws_instance/aws"
  version            = "1.5"
  name_prefix        = "${var.name_prefix}"
  instance_type      = "${var.instance_type}"
  ingress_cidr_block = "${var.ingress_cidr_block}"
}

output "AWS_Address" {
  value = "${module.aws_instance.public_ip}"
}

output "private_key" {
  value = "${module.aws_instance.private_key_pem}"
}

output "public_key" {
  value = "${module.aws_instance.public_key_pem}"
}

output "aws_keypair_name" {
  value = "${module.aws_instance.aws_keypair_name}"
}Patricks-MacBook-Pro:myapp patrickpresto$ cat variables.tf
variable "name_prefix" {
  description = "Enter your name or unique description here."
}

variable "instance_type" {
  description = "instance size (default: t2.micro)"
  type        = "string"
  default     = "t2.micro"
}

variable "ingress_cidr_block" {
  description = "WARNING: USING 0.0.0.0/0 IS INSECURE! (ex: <public.ipaddress>/32)"
  type        = "string"
  default     = "157.131.174.226/32"
}
