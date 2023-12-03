
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc with alias"
  cidr = "10.0.0.0/16"

  azs = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  map_public_ip_on_launch = true

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}
