---
name: terraform-gcp
description: Provision GCP infrastructure with Terraform. Configure providers and deploy Google Cloud resources. Use when implementing IaC for GCP.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Terraform GCP

Provision Google Cloud infrastructure with Terraform.

## Provider Configuration

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket = "tf-state-bucket"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
```

## Example Resources

```hcl
resource "google_compute_network" "vpc" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_instance" "vm" {
  name         = "web-server"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc.name
  }
}
```

## Best Practices

- Use service accounts for authentication
- Store state in GCS
- Use labels consistently
- Implement least-privilege IAM
