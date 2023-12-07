include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    vpc_id = "vpc-null"
    public_subnet_ids  = ["subnet-00112233445566778"]
    private_subnet_ids = ["subnet-00112233445566778"]
  }
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  public_subnet_ids  = dependency.vpc.outputs.public_subnet_ids
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  region = "eu-north-1"
}