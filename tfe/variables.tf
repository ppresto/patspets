variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "prefix" {
  description = "Enter your name or unique description here."
}

variable "instance_type" {
  description = "instance size (default: t2.micro)"
  type        = string
  default     = "t2.micro"
}

variable "ingress_cidr_block" {
  description = "WARNING: USING 0.0.0.0/0 IS INSECURE! (ex: <public.ipaddress>/32)"
  type        = string
  default     = "157.131.174.226/32"
}

variable "vpc_cidrs_public" {
  description = "VPC CIDR blocks for public subnets, defaults to \"10.139.1.0/24\", \"10.139.2.0/24\", and \"10.139.3.0/24\"."
  type        = list(any)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "cidr_egress" {
  type    = list(any)
  default = ["0.0.0.0/0", ]
}

variable "organization" {}

variable "tags" {
  default = {
    TTL   = 8
    owner = "presto"
  }
}