provider "google" {
  project     = "david-emad-project"
  region      = "europe-west1"
  credentials = file("/home/david/Downloads/david-emad-project-a80c0c2977e0.json")
}

resource "google_compute_network" "vpc_network" {
  project                 = "david-emad-project"
  name                    = "vpc-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}
resource "google_compute_subnetwork" "management-subnet" {
  name          = "management-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west1"
  network       = google_compute_network.vpc_network.id
#   secondary_ip_range {
#     range_name    = "tf-test-secondary-range-update1"
#     ip_cidr_range = "192.168.10.0/24"
#   }
}
resource "google_compute_subnetwork" "restricted-subnet" {
  name          = "restricted-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = "europe-west1"
  network       = google_compute_network.vpc_network.id
#   secondary_ip_range {
#     range_name    = "tf-test-secondary-range-update1"
#     ip_cidr_range = "192.168.10.0/24"
#   }
 }


resource "google_compute_router" "router" {
  name    = "my-router"
  region  = google_compute_subnetwork.management-subnet.region
  network = google_compute_network.vpc_network.id

  bgp {
    asn = 64514
  }
}
resource "google_compute_address" "address" {
  name   = "nat-address"
  region = google_compute_subnetwork.management-subnet.region
}
resource "google_compute_router_nat" "nat" {
  name                               = "nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.address.self_link]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.management-subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

