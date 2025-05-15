output "instance_group" {
  value = google_compute_region_instance_group_manager.default.instance_group
}

output "ssh_private_key_pem" {
  value     = tls_private_key.my_ssh_key.private_key_pem
  sensitive = true
}

output "ssh_public_key_openssh" {
  value = tls_private_key.my_ssh_key.public_key_openssh
}

output "load_balancer_ip" {
  value = google_compute_global_forwarding_rule.default.ip_address
}

output "vm_ip" {
  value = google_compute_global_forwarding_rule.default.ip_address
}

