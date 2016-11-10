output "names" {
  value = "${join(",", aws_instance.nomad_client.*.id)}"
}

output "private_ips" {
  value = "${join(",", aws_instance.nomad_client.*.private_ip)}"
}