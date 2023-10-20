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