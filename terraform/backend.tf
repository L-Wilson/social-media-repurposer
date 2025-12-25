terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket  = "terraform-state-backend-133954050615"
    region  = "eu-central-1"
    encrypt = true
    # Rest of values provided at init via backend config vars
  }
}
