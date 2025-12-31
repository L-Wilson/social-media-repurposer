output "service_url" {
  description = "App Runner service URL"
  value       = "https://${aws_apprunner_service.main.service_url}"
}

output "service_arn" {
  description = "ARN of the App Runner service"
  value       = aws_apprunner_service.main.arn
}

output "service_id" {
  description = "ID of the App Runner service"
  value       = aws_apprunner_service.main.service_id
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.main.repository_url
}

output "custom_domain_validation_records" {
  description = "DNS validation records for custom domain"
  value = var.domain_name != "" && length(aws_apprunner_custom_domain_association.main) > 0 ? [
    for record in aws_apprunner_custom_domain_association.main[0].certificate_validation_records : {
      name   = record.name
      type   = record.type
      value  = record.value
      status = record.status
    }
  ] : []
}

output "deployment_instructions" {
  description = "Step-by-step deployment instructions"
  value       = <<-EOT

    ========================================================================
    AWS APP RUNNER DEPLOYMENT INSTRUCTIONS
    ========================================================================

    Your App Runner service has been created!

    Service URL: https://${aws_apprunner_service.main.service_url}

    ========================================================================
    DEPLOYMENT WORKFLOW
    ========================================================================

    STEP 0: SETUP SECRETS MANAGER (ONE-TIME)
    ========================================================================

    Before deploying, create the OpenAI API key secret in AWS Secrets Manager:

    # Option A: Using AWS CLI
    aws secretsmanager create-secret \
      --name ${var.service_name}/openai-api-key \
      --secret-string "sk-your-openai-api-key-here" \
      --region ${var.aws_region}

    # Option B: Using AWS Console
    1. Go to AWS Console > Secrets Manager
    2. Click "Store a new secret"
    3. Select "Other type of secret"
    4. Enter your OpenAI API key as plaintext value
    5. Name the secret: ${var.service_name}/openai-api-key
    6. Click "Store"

    To update the secret later:
    aws secretsmanager update-secret \
      --secret-id ${var.service_name}/openai-api-key \
      --secret-string "sk-new-key" \
      --region ${var.aws_region}

    Then force a new App Runner deployment to pick up the updated value.

    ========================================================================
    1. BUILD AND PUSH DOCKER IMAGE TO ECR
    ========================================================================

    # Login to ECR
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.main.repository_url}

    # Build and push Docker image (from your app root directory)
    cd backend
    docker build --platform linux/amd64 -t ${var.service_name}:latest .
    docker tag ${var.service_name}:latest ${aws_ecr_repository.main.repository_url}:latest
    docker push ${aws_ecr_repository.main.repository_url}:latest

    2. APP RUNNER AUTO-DEPLOYMENT
    ========================================================================

    App Runner is configured with auto-deployment enabled!

    When you push a new image to ECR with the :latest tag, App Runner will:
    - Automatically detect the new image
    - Pull and deploy it
    - Perform health checks on /health endpoint
    - Route traffic to the new version once healthy
    - Zero-downtime deployment!

    You can monitor the deployment in the AWS Console:
    https://console.aws.amazon.com/apprunner/home?region=${var.aws_region}#/services/${aws_apprunner_service.main.service_id}

    3. CUSTOM DOMAIN SETUP (mycreatorkit.com)
    ========================================================================

    Your domain mycreatorkit.com is configured for App Runner!

    After running terraform apply, you'll see validation records in the output.
    Add these records to Cloudflare DNS to verify domain ownership:

    a. Go to Cloudflare Dashboard > mycreatorkit.com > DNS

    b. Add the validation records shown in terraform output
       (They will be CNAME records for SSL certificate validation)

    c. Once validated (usually 1-5 minutes), add the final CNAME record:
       - Type: CNAME
       - Name: @ (for root domain)
       - Target: ${aws_apprunner_service.main.service_url}
       - Proxy status: DNS only (gray cloud icon)

    d. For www subdomain (automatically configured):
       - Type: CNAME
       - Name: www
       - Target: ${aws_apprunner_service.main.service_url}
       - Proxy status: DNS only (gray cloud icon)

    Once DNS propagates, your app will be live at:
    - https://mycreatorkit.com
    - https://www.mycreatorkit.com

    ========================================================================
    CONFIGURATION
    ========================================================================

    - CPU: ${var.cpu} (1024 = 1 vCPU)
    - Memory: ${var.memory} MB
    - Auto-scaling: ${var.min_size}-${var.max_size} instances
    - Max concurrency: ${var.max_concurrency} requests per instance
    - Health check: HTTP on /health

    ========================================================================
    UPDATING SECRETS
    ========================================================================

    To update the OpenAI API key:

    1. Update the secret in Secrets Manager:
       aws secretsmanager update-secret \
         --secret-id ${var.service_name}/openai-api-key \
         --secret-string "sk-new-key" \
         --region ${var.aws_region}

    2. Force a new deployment to pick up the updated secret:
       aws apprunner start-deployment \
         --service-arn ${aws_apprunner_service.main.arn} \
         --region ${var.aws_region}

    ========================================================================
    COST ESTIMATE
    ========================================================================

    App Runner pricing (us-east-1):
    - Provisioned resources: ~$25-30/month (1 vCPU, 2GB, 1 instance always on)
    - Request-based: $0.000004 per request
    - Build: $0.005 per build minute (only when deploying)

    ECR storage: ~$0.10/GB/month

    Estimated total: $25-35/month for low-moderate traffic

    ========================================================================
    MONITORING
    ========================================================================

    View logs and metrics in CloudWatch:
    - Log group: /aws/apprunner/${var.service_name}/${aws_apprunner_service.main.service_id}

    Or use AWS CLI:
    aws apprunner list-operations --service-arn ${aws_apprunner_service.main.arn} --region ${var.aws_region}

    ========================================================================
  EOT
}
