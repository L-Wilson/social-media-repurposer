output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnets" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for pushing Docker images"
  value       = aws_ecr_repository.main.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = aws_lb.main.zone_id
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.main.arn
}

output "application_url" {
  description = "URL of the application"
  value       = "https://${var.domain_name}"
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for ECS task logs"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "next_steps" {
  description = "Post-deployment instructions"
  value       = <<-EOT

    ========================================================================
    POST-DEPLOYMENT INSTRUCTIONS
    ========================================================================

    IMPORTANT: Domain uses Cloudflare Registrar with Cloudflare nameservers.
    DNS records must be managed in Cloudflare (not Route53).

    1. VALIDATE ACM CERTIFICATE IN CLOUDFLARE
    ========================================================================

    Get certificate validation records:
    - Go to AWS Console: https://console.aws.amazon.com/acm/home?region=${var.aws_region}
    - Find certificate for: ${var.domain_name}
    - Click on certificate ID
    - Copy the CNAME validation records (you'll see 2 records: one for apex, one for www)

    Add validation records to Cloudflare:
    - Go to: https://dash.cloudflare.com/
    - Select domain: ${var.domain_name}
    - Go to: DNS > Records
    - Click "Add record"
    - Type: CNAME
    - Name: (paste the name from ACM, remove the domain suffix)
    - Target: (paste the value from ACM)
    - Proxy status: DNS only (grey cloud, not proxied)
    - TTL: Auto
    - Repeat for both validation records
    - Save

    Wait for validation:
    - Certificate validation takes 5-30 minutes
    - Check status in AWS Console or run:
      aws acm describe-certificate --certificate-arn ${aws_acm_certificate.main.arn} --region ${var.aws_region}

    2. CREATE DNS RECORDS IN CLOUDFLARE
    ========================================================================

    ALB DNS Name: ${aws_lb.main.dns_name}

    Add DNS records in Cloudflare:
    - Go to: https://dash.cloudflare.com/
    - Select domain: ${var.domain_name}
    - Go to: DNS > Records

    Record 1 (Apex domain):
    - Type: CNAME
    - Name: @ (or ${var.domain_name})
    - Target: ${aws_lb.main.dns_name}
    - Proxy status: Proxied (orange cloud) - recommended for DDoS protection
    - TTL: Auto
    - Save

    Record 2 (WWW subdomain):
    - Type: CNAME
    - Name: www
    - Target: ${var.domain_name}
    - Proxy status: Proxied (orange cloud)
    - TTL: Auto
    - Save

    DNS propagation: 1-5 minutes with Cloudflare

    3. BUILD AND PUSH DOCKER IMAGE
    ========================================================================

    # Login to ECR
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.main.repository_url}

    # Build and push Docker image
    docker build -t ${var.service_name}:latest .
    docker tag ${var.service_name}:latest ${aws_ecr_repository.main.repository_url}:latest
    docker push ${aws_ecr_repository.main.repository_url}:latest

    # Force ECS to deploy the new image
    aws ecs update-service --cluster ${aws_ecs_cluster.main.name} --service ${aws_ecs_service.app.name} --force-new-deployment --region ${var.aws_region}

    NOTE: ECR is currently set to MUTABLE tags for simple development workflow.
    Consider switching to IMMUTABLE with versioned tags (git SHA, timestamps) when setting up CI/CD.

    4. MONITOR DEPLOYMENT
    ========================================================================

    # Check ECS service status
    aws ecs describe-services --cluster ${aws_ecs_cluster.main.name} --services ${aws_ecs_service.app.name} --region ${var.aws_region}

    # View CloudWatch logs (live tail)
    aws logs tail ${aws_cloudwatch_log_group.ecs.name} --follow --region ${var.aws_region}

    # Check certificate validation status
    aws acm describe-certificate --certificate-arn ${aws_acm_certificate.main.arn} --region ${var.aws_region}

    5. ACCESS YOUR APPLICATION
    ========================================================================

    HTTP (will redirect to HTTPS):
      http://${var.domain_name}
      http://www.${var.domain_name}

    HTTPS:
      https://${var.domain_name}
      https://www.${var.domain_name}

    ALB Direct (for testing before DNS):
      http://${aws_lb.main.dns_name}

    6. VIEW LOGS
    ========================================================================

    # Tail logs in real-time
    aws logs tail ${aws_cloudwatch_log_group.ecs.name} --follow --region ${var.aws_region}

    # View logs in AWS Console
    https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/${replace(aws_cloudwatch_log_group.ecs.name, "/", "$252F")}

    7. TROUBLESHOOTING
    ========================================================================

    If the service doesn't start:
    - Check ECS task logs in CloudWatch
    - Verify Docker image is in ECR with 'latest' tag
    - Check security group rules allow traffic
    - Ensure task has enough CPU/Memory

    If DNS doesn't resolve:
    - Verify CNAME records are correct in Cloudflare
    - Check Cloudflare proxy status (orange cloud)
    - Wait for DNS propagation (usually 1-5 minutes)
    - Test with: dig ${var.domain_name}
    - Test ALB directly: curl ${aws_lb.main.dns_name}

    If HTTPS doesn't work:
    - Wait for ACM certificate validation (check in AWS Console)
    - Verify validation CNAME records exist in Cloudflare
    - Ensure validation records have "DNS only" (grey cloud, not proxied)
    - Certificate validation takes 5-30 minutes
    - Check status: aws acm describe-certificate --certificate-arn ${aws_acm_certificate.main.arn} --region ${var.aws_region}

    ========================================================================
    ESTIMATED MONTHLY COSTS (Budget-Optimized)
    ========================================================================

    - Fargate Spot (256 CPU, 512 MB, 1 task):  ~$3-4/month
    - Application Load Balancer:               ~$16/month
    - CloudWatch Logs (7 day retention):       ~$1-2/month
    - ECR Storage:                             ~$0.10/GB/month
    - Data Transfer:                           Variable
    - Cloudflare DNS:                          Free (included with domain)

    Total Estimated Cost: ~$20-22/month

    ========================================================================

  EOT
}
