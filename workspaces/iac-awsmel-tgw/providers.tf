provider "aws" {
  region = "ap-southeast-4"
  assume_role {
    role_arn     = "arn:aws:iam::681696216801:role/DEVTerraformDeploymentRole"
    session_name = "TerraformCloudDeployment"
  }
  # Default tags applied to all resources
  default_tags {
    tags = {
      Environment = "Production"
      Project     = "DOEVic-Melbourne"
      ManagedBy   = "Terraform"
      Region      = "ap-southeast-4"
    }
  }
}