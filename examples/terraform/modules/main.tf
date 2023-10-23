
provider "aws" {
  region = var.region
}

module "funny_ec2" {
  source               = "./module1"
  ssh_public_key_file  = var.ssh_public_key_file
  ssh_private_key_file = var.ssh_private_key_file
}

output "public_ip" {
  value     = module.funny_ec2.ec2_public_ip
  sensitive = true
}