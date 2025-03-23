resource "google_compute_network" "custom_vpc" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
}


# SUBNET
resource "google_compute_subnetwork" "custom_subnet" {
  name          = "custom-subnet"
  region        = "us-central1"
  network       = google_compute_network.custom_vpc.id
  ip_cidr_range = "10.10.0.0/16"
}


# FIREWALL RULES

# Allow internal communication
resource "google_compute_firewall" "allow-internal" {
  name    = "allow-internal"
  network = google_compute_network.custom_vpc.id

  allow {
    protocol = "all"
  }

  source_ranges = ["10.10.0.0/16"]
}

# Allow external SSH, RDP, and ICMP
resource "google_compute_firewall" "allow-external" {
  name    = "allow-external"
  network = google_compute_network.custom_vpc.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Allow GKE communication
resource "google_compute_firewall" "allow-gke" {
  name    = "allow-gke"
  network = google_compute_network.custom_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["443", "10250", "15017"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# GKE CLUSTER
resource "google_container_cluster" "primary" {
  project  = var.project
  name     = "my-gke-cluster"
  location = "us-central1"

  network    = google_compute_network.custom_vpc.id
  subnetwork = google_compute_subnetwork.custom_subnet.id
#  min_master_version = var.k8s_version
  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count       = 1
}


# NODE POOL
resource "google_container_node_pool" "primary_nodes" {
  name       = "my-node-pool"
  project = google_container_cluster.primary.project
  cluster = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location
#  version = var.k8s_version
  node_locations = ["us-central1-a"]
  node_count = var.node_count

  #  node_count = var.node-count
  node_config {
    image_type   = "UBUNTU_CONTAINERD"
    disk_size_gb = 10
    disk_type = "pd-standard"
    machine_type = "e2-medium"
  }
  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }
  management {
    auto_repair = true
    auto_upgrade = true
  }
}


# Scale the Cluster from 1 to 2 Nodes
# If you prefer not to use Terraform for this change, you can scale the nodes manually:
# gcloud container clusters resize my-gke-cluster --num-nodes=2 --region=us-central1
