provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance_template" "apache_template" {
  name_prefix = "apache-template"
  machine_type = "e2-micro"

  tags = ["apache"]

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("startup.sh")

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_compute_instance_group_manager" "apache_mig" {
  name               = "apache-mig"
  base_instance_name = "apache"
  version {
    instance_template = google_compute_instance_template.apache_template.id
  }
  target_size = 2

  auto_healing_policies {
    health_check      = google_compute_health_check.apache_check.id
    initial_delay_sec = 60
  }
}

resource "google_compute_autoscaler" "apache_autoscaler" {
  name   = "apache-autoscaler"
  target = google_compute_instance_group_manager.apache_mig.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}

resource "google_compute_health_check" "apache_check" {
  name               = "apache-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 3

  http_health_check {
    port = 80
  }
}
