provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance_template" "apache_template" {
  name_prefix  = "apache-template"
  machine_type = "e2-micro"

  tags = ["http-server"]

  metadata = {
    enable-oslogin = "TRUE"
  }

  disk {
    auto_delete  = true
    boot         = true
    source_image = "debian-cloud/debian-11"
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt update
    apt install -y apache2
    systemctl enable apache2
    systemctl start apache2
  EOT
}

resource "google_compute_region_instance_group_manager" "apache_group" {
  name               = "apache-group"
  region             = var.region
  base_instance_name = "apache"
  version {
    instance_template = google_compute_instance_template.apache_template.id
  }
  target_size = 2
}

resource "google_compute_autoscaler" "apache_autoscaler" {
  name   = "apache-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.apache_group.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}

resource "google_compute_health_check" "http" {
  name = "http-health-check"
  http_health_check {
    port = 80
  }
}

resource "google_compute_backend_service" "apache_backend" {
  name          = "apache-backend"
  protocol      = "HTTP"
  port_name     = "http"
  health_checks = [google_compute_health_check.http.id]
  backend {
    group = google_compute_region_instance_group_manager.apache_group.instance_group
  }
}

resource "google_compute_url_map" "apache_map" {
  name            = "apache-map"
  default_service = google_compute_backend_service.apache_backend.id
}

resource "google_compute_target_http_proxy" "apache_proxy" {
  name   = "apache-proxy"
  url_map = google_compute_url_map.apache_map.id
}

resource "google_compute_global_address" "apache_ip" {
  name = "apache-ip"
}

resource "google_compute_global_forwarding_rule" "apache_forwarding" {
  name        = "apache-forwarding"
  ip_address  = google_compute_global_address.apache_ip.address
  target      = google_compute_target_http_proxy.apache_proxy.id
  port_range  = "80"
}
