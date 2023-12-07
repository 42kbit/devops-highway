
locals {
  packer_ami_filename = "${path.cwd}/_packer_generated_ami.txt"
  # https://stackoverflow.com/a/66501021
  # this gets hash of the directory, by hasing the hash concatination of each file
  provision_hash = sha1(join("", [for f in fileset("${path.cwd}/provision_info", "*") : filesha1("${path.cwd}/provision_info/${f}")]))
}

resource "null_resource" "run_packer" {
  triggers = {
    reprovision_needed  = local.provision_hash
    packer_ami_filename = local.packer_ami_filename
  }
  provisioner "local-exec" {
    command = <<-EOT
      packer init ${path.cwd}/provision_info/aws-ubuntu.pkr.hcl; \
      packer build -machine-readable \
      ${path.cwd}/provision_info/aws-ubuntu.pkr.hcl \
        > ${local.packer_ami_filename}
    EOT
  }

  # remove file
  provisioner "local-exec" {
    when    = destroy
    command = "rm ${self.triggers.packer_ami_filename}"
  }
}

data "aws_ami" "packer_generated" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["my-packer-ami-*"]
  }

  # can also filter by tag, if working on separate env

  depends_on = [null_resource.run_packer]
}

resource "null_resource" "destroy_packer" {
  triggers = {
    packer_ami = data.aws_ami.packer_generated.id
  }

  # deregister ami
  provisioner "local-exec" {
    when    = destroy
    command = "aws ec2 deregister-image --image-id ${self.triggers.packer_ami}"
  }

  # deregister snapshots
  provisioner "local-exec" {
    when = destroy
    environment = {
      AMI_ID = self.triggers.packer_ami
    }
    command = file("${path.cwd}/deregister_snapshots.sh")
  }
}

output "jenkins_ami" {
  value = data.aws_ami.packer_generated.id
}
