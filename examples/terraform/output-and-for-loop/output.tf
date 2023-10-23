output "machine_public_ip" {
  value = [for i in aws_instance.hello_variables : i.public_ip]
  # same thing i guess
  # value = aws_instance.hello_variables[*].public_ip
  sensitive = true # use terraform output -raw machine_public_ip
}