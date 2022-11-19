provider "google" {
        project     = "my-first-project-363114"
        region      = "europe-north1"
        zone        = "europe-north1-a"
}

variable "vm_name_input" {
  type        = string
}

resource "google_compute_address" "static" {
  name = "my-address"
}

# Create a single Compute Engine instance
resource "google_compute_instance" "default" {
  name         = var.vm_name_input
  machine_type = "f1-micro"
  zone         = "europe-north1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
      nat_ip = google_compute_address.static.address
    }
  }
}

output "vm_name" {
  value = var.vm_name_input
}

output "public_ip" {
  value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-custom-mode-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "my-custom-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-north1"
  network       = google_compute_network.vpc_network.id
}
