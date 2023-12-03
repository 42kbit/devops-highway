include "root" {
  path = find_in_parent_folders()
}

# so internaly, dependency will modify dependency graph, in this case:
# 1. vpc ("../network") will be done first
# 2. terragrunt then will make something simmilar to 
#       data "terraform_remote_state" "state"
#    and fetch data and pass to another module(s),
#     when this module is deployed.

dependency "vpc" {
  config_path = "../network"
  
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    # i want to kms rn ngl
    # terraform resolves unknown variable like that with (known after apply)
    # but terragrunt requires us to do this bullshiterry and come up with
    # this crap. Well... this is just how it is...
    vpc_id = "vpc-null"
    public_subnet_ids  = ["subnet-00112233445566778"]
    private_subnet_ids = ["subnet-00112233445566778"]
  }
}

# Others go to "terraform.tfvars"
#
# ec2_test_instances_info = {
#   instance_type       = "t3.micro"
#   public_key_filepath = "~/.ssh/my-ec2-key.pub"
# }
#
# Otherwise this would ask for cli input i belive.

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  public_subnet_ids  = dependency.vpc.outputs.public_subnet_ids
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
}