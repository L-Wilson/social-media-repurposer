# ==============================================================================
# AWS Secrets Manager
# ==============================================================================
#
# This file manages secrets using AWS Secrets Manager for secure storage
# of sensitive values like API keys.
#
# SETUP INSTRUCTIONS:
# 1. Create the secret manually before running terraform:
#  aws secretsmanager create-secret \
#    --name social-media-repurposer/openai-api-key \
#    --secret-string "sk-***" \
#    --region eu-central-1
#
# 2. Or use the AWS Console:
#    - Go to Secrets Manager
#    - Click "Store a new secret"
#    - Select "Other type of secret"
#    - Key: (leave as plaintext)
#    - Value: sk-your-openai-api-key-here
#    - Name: social-media-repurposer/openai-api-key
#
# 3. Run terraform apply - it will read the secret and inject it into App Runner
#
# TO UPDATE THE SECRET:
# aws secretsmanager update-secret \
#   --secret-id social-media-repurposer/openai-api-key \
#   --secret-string "sk-new-key" \
#   --region us-east-1
#
# Then redeploy App Runner to pick up the new value.
#
# ==============================================================================

# Data source to read the OpenAI API key from Secrets Manager
data "aws_secretsmanager_secret" "openai_api_key" {
  name = "${var.service_name}/openai-api-key"
}

data "aws_secretsmanager_secret_version" "openai_api_key" {
  secret_id = data.aws_secretsmanager_secret.openai_api_key.id
}
