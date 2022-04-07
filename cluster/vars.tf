variable "instance_types" {
  default = ["t3a.large"]
}

variable "environment" {
    default = "plana-cluster"
}

variable "region" {
    default = "eu-central-1"
}

variable "desired_capacity" {
  default   = 2
}

variable "min_capacity" {
  default   = 2
}