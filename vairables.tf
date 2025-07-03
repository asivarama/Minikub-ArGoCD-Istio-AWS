variable "region" {
  default = "ap-south-1"
}

variable "key_name" {
  description = "The name of the existing AWS key pair (downloaded the .pem file)"
  default     = "my-aws-key"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "disk_size" {
  default = 30
}
