variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"
}
variable "ssh_public_key_file" {
  description = "SSH Public key to establish ec2 connection"
  type        = string
}

variable "ssh_private_key_file" {
  description = "SSH Private key to establish ec2 connection (will not be sent anywhere)"
  type        = string
}