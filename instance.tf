resource "google_compute_instance" "private-vm" {
  name         = "private-vm"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"
  metadata_startup_script = "#! /bin/bash sudo apt update"
  
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      type = "pd-standard"
      size = 10
    }
  }
  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.management-subnet.id

  }

}

resource "google_compute_firewall" "allow-ingress-from-iap" {
  name    = "allow-ingress-from-iap"
  network = google_compute_network.vpc_network.id
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"] # IP addresses that IAP uses for TCP forwarding.


  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
}