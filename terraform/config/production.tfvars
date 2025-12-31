aws_region   = "eu-central-1"
environment  = "production"
service_name = "social-media-repurposer"
domain_name  = "api.mycreatorkit.com"

# App Runner Configuration
cpu             = 1024 # 1 vCPU
memory          = 2048 # 2 GB
max_concurrency = 100  # requests per instance
min_size        = 1    # minimum instances
max_size        = 2    # maximum instances
