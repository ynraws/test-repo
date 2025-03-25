resource "google_compute_network" "custom_network" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom-subnet" {
  name          = "custom-subnetwork"
  ip_cidr_range = "10.10.0.0/16"
  region        = var.region
  network       = google_compute_network.custom_network.id
}

# Firewall-1 for Internal Communication
resource "google_compute_firewall" "allow-internal" {
  name    = "internal-firewall"
  network = google_compute_network.custom_network.id

  allow {
    protocol = "all"
  }

  source_ranges = ["10.10.0.0/16"]
}

# Firewall-2 for External Access SSH, icmp, RDP
resource "google_compute_firewall" "allow-external" {
  name    = "external-firewall"
  network = google_compute_network.custom_network.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Firewall-3 for GKE Communication
resource "google_compute_firewall" "allow-gke" {
  name    = "gke-firewall"
  network = google_compute_network.custom_network.id

  allow {
    protocol = "tcp"
    ports    = ["443", "10250", "15017"]
  }

  source_ranges = ["0.0.0.0/0"]
}


# GKE Cluster
resource "google_container_cluster" "primary" {
  project             = var.project
  name                = "terraform-gke-cluster"
  location            = var.region
  network             = google_compute_network.custom_network.id
  subnetwork          = google_compute_subnetwork.custom-subnet.id
  deletion_protection = false
  remove_default_node_pool = true
  initial_node_count       = 1  
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name           = "my-node-pool"
  cluster        = google_container_cluster.primary.name
  location       = google_container_cluster.primary.location
  node_count     = 1  

  node_config {
    machine_type   = "e2-medium"  # Use a smaller instance to reduce storage requirements
    disk_size_gb   = "15"
    disk_type      = "pd-standard"
    image_type     = "UBUNTU_CONTAINERD"
  }
}
