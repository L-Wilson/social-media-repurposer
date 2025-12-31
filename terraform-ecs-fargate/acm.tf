# ==============================================================================
# ACM SSL Certificate
# ==============================================================================
#
# DNS SETUP:
# - Domain registered with Cloudflare Registrar
# - Cloudflare nameservers required (cannot change)
# - Using Cloudflare for DNS management (manual configuration)
# - ACM certificate validation done via Cloudflare DNS
# - Route53 not used for this deployment
#
# CERTIFICATE VALIDATION:
# - After terraform apply, manually add CNAME records in Cloudflare
# - Get validation records from AWS Console (ACM service)
# - Certificate includes both apex and www subdomain
#
# ==============================================================================

resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = ["www.${var.domain_name}"]

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      name = "${var.domain_name}-certificate"
    }
  )
}
