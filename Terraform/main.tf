# main.tf
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance_template" "default" {
  name_prefix = "apache-template"
  machine_type = "e2-medium"

  tags = ["http-server"]

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOT
    sudo apt update
    sudo apt install -y apache2
    sudo systemctl enable apache2
    sudo systemctl start apache2
  EOT
}

resource "google_compute_region_instance_group_manager" "default" {
  name               = "apache-mig"
  base_instance_name = "apache-instance"
  region             = var.region
  version {
    instance_template = google_compute_instance_template.default.id
  }

  target_size = 2  # Start with 2 instances
  auto_healing_policies {
    health_check      = google_compute_health_check.default.id
    initial_delay_sec = 300
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
  health_checks                   = [google_compute_health_check.default.id]
  load_balancing_scheme           = "EXTERNAL"
  connection_draining_timeout_sec = 0

  backend {
    group = google_compute_region_instance_group_manager.default.instance_group
  }

  depends_on = [google_compute_health_check.default]
}


resource "google_compute_url_map" "default" {
  name            = "apache-url-map"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_target_http_proxy" "default" {
  name   = "apache-http-proxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "apache-forwarding-rule"
  target                = google_compute_target_http_proxy.default.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "TCP"
}

