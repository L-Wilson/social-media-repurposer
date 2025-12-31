locals {
  common_tags = {
    project     = "social-media-repurposer"
    environment = "${var.environment}"
    managedBy   = "terraform"
    owner       = "lindsay"
  }
}

# Usage example - apply tags to a resource:
# resource "aws_example" "demo" {
#   tags = local.common_tags
# }

# Usage example - merge with additional tags:
# resource "aws_example" "demo" {
#   tags = merge(
#     local.common_tags,
#     {
#       Name = "specific-resource-name"
#     }
#   )
# }
