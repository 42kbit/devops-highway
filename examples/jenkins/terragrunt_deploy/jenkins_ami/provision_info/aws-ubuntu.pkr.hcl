
# here we define packer settings or plugins
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  #    ^^^^^^^^^^^^ ^^^^^^^^
  #   builder type    name

  # this builder type runs an source ami
  # provisions it
  # then repackages it.

  ami_name      = "my-packer-ami-${local.timestamp}"
  instance_type = "t3.micro"
  region        = "eu-north-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # cannonical
  }
  ssh_username = "ubuntu"
}

# this block defines how to provision sources that we provided.
# sources are created defined by builder behavior, and can be provisioned
# by connector behaviour
build {
  # which sources to provision with this block
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
   
  provisioner "ansible" {
    # https://github.com/hashicorp/packer-plugin-ansible/issues/100
    # https://github.com/hashicorp/packer/issues/11783#issuecomment-1137052770
    extra_arguments = [ "--scp-extra-args", "'-O'" ]

    playbook_file = "${path.root}/playbook.yml"
  }
}