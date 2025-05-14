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
