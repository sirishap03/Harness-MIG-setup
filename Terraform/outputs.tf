output "instance_group_name" {
  description = "The name of the managed instance group"
  value       = google_compute_region_instance_group_manager.default.name
}

output "backend_service_name" {
  description = "The backend service used for load balancing"
  value       = google_compute_backend_service.default.name
}

output "load_balancer_ip" {
  description = "The external IP address of the Load Balancer"
  value       = google_compute_global_forwarding_rule.default.ip_address
}

output "vm_ip" {
  value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

