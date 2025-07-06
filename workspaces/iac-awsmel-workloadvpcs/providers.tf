provider "aws" {
  alias  = "app1"
  region = "ap-southeast-4"
  assume_role {
    role_arn = "arn:aws:iam:248896117066:role/DEVTerraformDeploymentRole"
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

# provider "aws" {
#   alias  = "app2"
#   region = "ap-southeast-4"
#   assume_role {
#     role_arn     = "arn:aws:iam::xxxxxxx:role/DEVTerraformDeploymentRole"
#     session_name = "TerraformCloudDeployment"
#   }
#   # Default tags applied to all resources
#   default_tags {
#     tags = {
#       Environment = "Production"
#       Project     = "DOEVic-Melbourne"
#       ManagedBy   = "Terraform"
#       Region      = "ap-southeast-4"
#     }
#   }
# }

# Provider for the Transit Account (to access Transit Gateway resources)
provider "aws" {
  alias  = "app2_account"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::248896117066:role/DEVTerraformDeploymentRole"
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

provider "aws" {
  alias  = "transit_account"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::681696216801:role/DEVTerraformDeploymentRole"
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
