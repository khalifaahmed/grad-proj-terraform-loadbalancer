terraform {
  #backend "s3" {
  #   bucket = "grad--proj--bucket"
  #   key    = "Terraform/grad-proj-general/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.provider_region
}
