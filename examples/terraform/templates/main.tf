terraform {}

data "template_file" "policy" {
  template = file("${path.module}/file.tpl")

  vars = {
    name = "deb" 
  }
}

output "policy" {
  value = "This is templated value: ${data.template_file.policy.rendered}"
}

# heres another example

locals {
  rendered = templatefile("${path.module}/file.tpl", {
    name = "another_deb"
  })
}

output "policy_by_templatefile" {
  value = "This is templatefile value: ${local.rendered}"
}