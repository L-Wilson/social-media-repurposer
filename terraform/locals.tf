locals {
  common_tags = {
    project     = "social-media-repurposer"
    environment = var.environment
    managedBy   = "terraform"
    owner       = "lindsay"
  }
}
