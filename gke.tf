
resource "google_container_cluster" "private-cluster" {
  name     = "private-cluster"
  location = "europe-west1"
  initial_node_count = 2
  network = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.restricted-subnet.id
  release_channel {
    channel = "STABLE"
  }
  
  master_authorized_networks_config  {
    cidr_blocks {
      cidr_block   = "10.0.1.0/24"
      display_name = "trusted-networks-from-private-vm"
    }
  }
  ip_allocation_policy {
    #any ip range that does not ovelap with subnet range
    cluster_ipv4_cidr_block  = "10.1.0.0/16" 
    services_ipv4_cidr_block = "10.2.0.0/16"
  }
  private_cluster_config {
     master_ipv4_cidr_block = "172.16.0.32/28"
     # internal IP address range for the control plane
     enable_private_nodes = true
     enable_private_endpoint = true
  }
  
}


