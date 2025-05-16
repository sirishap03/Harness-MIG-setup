output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The region where resources are deployed"
  value       = var.region
}

output "zone" {
  description = "The zone where instances are located"
  value       = var.zone
}

output "instance_template" {
  description = "The name of the instance template used in the MIG"
  value       = google_compute_instance_template.default.name
}

output "mig_name" {
  description = "The name of the managed instance group"
  value       = google_compute_instance_group_manager.default.name
}

output "autoscaler_status" {
  description = "The name of the autoscaler linked to the MIG"
  value       = google_compute_autoscaler.default.name
}

output "backend_service" {
  description = "The name of the backend service used by the load balancer"
  value       = google_compute_backend_service.default.name
}

output "health_check" {
  description = "The health check configured for load balancer"
  value       = google_compute_health_check.http.name
}

output "url_map" {
  description = "The URL map used by the load balancer"
  value       = google_compute_url_map.default.name
}

output "http_proxy" {
  description = "The target HTTP proxy for the load balancer"
  value       = google_compute_target_http_proxy.default.name
}

output "forwarding_rule" {
  description = "The forwarding rule for the load balancer"
  value       = google_compute_global_forwarding_rule.default.name
}

output "load_balancer_ip" {
  description = "The external IP of the global HTTP load balancer"
  value       = google_compute_global_forwarding_rule.default.ip_address
}

output "load_balancer_url" {
  description = "URL to access Apache web server via load balancer"
  value       = "http://${google_compute_global_forwarding_rule.default.ip_address}"
}
