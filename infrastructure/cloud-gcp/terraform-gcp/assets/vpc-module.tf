# GCP VPC Module Template

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "main"
}

# VPC Network
resource "google_compute_network" "main" {
  name                    = "${var.project_name}-${var.environment}-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Public Subnet
resource "google_compute_subnetwork" "public" {
  name          = "${var.project_name}-${var.environment}-public"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.main.id
  project       = var.project_id

  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "10.2.0.0/20"
  }
}

# Private Subnet
resource "google_compute_subnetwork" "private" {
  name                     = "${var.project_name}-${var.environment}-private"
  ip_cidr_range            = "10.0.2.0/24"
  region                   = var.region
  network                  = google_compute_network.main.id
  project                  = var.project_id
  private_ip_google_access = true
}

# Cloud Router (for NAT)
resource "google_compute_router" "main" {
  name    = "${var.project_name}-${var.environment}-router"
  region  = var.region
  network = google_compute_network.main.id
  project = var.project_id
}

# Cloud NAT
resource "google_compute_router_nat" "main" {
  name                               = "${var.project_name}-${var.environment}-nat"
  router                             = google_compute_router.main.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewall - Allow SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.project_name}-${var.environment}-allow-ssh"
  network = google_compute_network.main.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

# Firewall - Allow Internal
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_name}-${var.environment}-allow-internal"
  network = google_compute_network.main.name
  project = var.project_id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/8"]
}

output "network_name" {
  value = google_compute_network.main.name
}

output "network_id" {
  value = google_compute_network.main.id
}

output "subnet_ids" {
  value = {
    public  = google_compute_subnetwork.public.id
    private = google_compute_subnetwork.private.id
  }
}
