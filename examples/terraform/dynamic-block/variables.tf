variable "region" {
  description = "AWS Region"
  type = string
  default = "eu-north-1"
}

variable "ami" {
  description = "AWS AMI"
  type = string
  default = "ami-0ea7dc624e77a15d5"
}

variable "instance_type" {
  description = "AWS Instance type"
  type = string
  default = "t3.micro"
}

variable "instance_count" {
  description = "Number of instances to create"
  type = number
  default = 1
}

variable "user_names" {
  description = "IAM Users"
  type = list(string)
  default = [ "user1", "user2", "user3" ]
}

variable "ssh_public_key_file" {
  description = "SSH Public key to establish ec2 connection"
  type = string
}

variable "ssh_private_key_file" {
  description = "SSH Private key to establish ec2 connection (will not be sent anywhere)"
  type = string
}