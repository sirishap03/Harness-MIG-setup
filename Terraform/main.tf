provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "tls_private_key" "my_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_instance_template" "default" {
  name_prefix  = "apache-template"
  machine_type = "e2-medium"

  tags = ["http-server"]

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network       = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "ansible:${tls_private_key.my_ssh_key.public_key_openssh}"
  }
}

resource "google_compute_health_check" "default" {
  name               = "apache-health-check"
  check_interval_sec = 10
  timeout_sec        = 5

  http_health_check {
    port = 80
  }
}

# Optional workaround: add a delay to ensure health check is ready
# resource "time_sleep" "wait_for_health_check" {
#   depends_on      = [google_compute_health_check.default]
#   create_duration = "20s"
# }

resource "google_compute_region_instance_group_manager" "default" {
  name               = "apache-mig"
  base_instance_name = "apache-instance"
  region             = var.region

  version {
    instance_template = google_compute_instance_template.default.id
  }

  target_size = 2

  auto_healing_policies {
    health_check      = google_compute_health_check.default.id
    initial_delay_sec = 300
  }
}

resource "google_compute_region_autoscaler" "default" {
  name   = "mig-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.default.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}

resource "google_compute_backend_service" "default" {
  name                            = "apache-backend-service"
  protocol                        = "HTTP"
  port_name                       = "http"
  timeout_sec                     = 10
  load_balancing_scheme           = "EXTERNAL"
  connection_draining_timeout_sec = 0

  health_checks = [google_compute_health_check.default.self_link]

  backend {
    group = google_compute_region_instance_group_manager.default.instance_group
  }

  depends_on = [
    google_compute_health_check.default
    # , time_sleep.wait_for_health_check # Uncomment this line if you enable time_sleep
  ]
}

resource "google_compute_url_map" "default" {
  name            = "apache-url-map"
  default_service = google_compute_backend_service.default.self_link
}

resource "google_compute_target_http_proxy" "default" {
  name    = "apache-http-proxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "apache-forwarding-rule"
  target                = google_compute_target_http_proxy.default.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "TCP"
}
