variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
}

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
