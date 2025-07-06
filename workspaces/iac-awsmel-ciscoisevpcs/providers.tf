# Provider for the Workload Account (where VPCs will be created)
provider "aws" {
  region = "ap-southeast-4"

  # Use service account with appropriate permissions in the Workload account
  assume_role {
    role_arn     = "arn:aws:iam::248896117066:role/DEVTerraformDeploymentRole"
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

# Provider for the Transit Account (to access Transit Gateway resources)
provider "aws" {
  alias  = "transit_account"
  region = "ap-southeast-4"

  # Use service account to assume role in Transit Account
  assume_role {
    role_arn = "arn:aws:iam::681696216801:role/DEVTerraformDeploymentRole"
  }

  # Default tags applied to all resources in transit account
  default_tags {
    tags = {
      Environment = "Production"
      Project     = "DOEVic-Melbourne"
      ManagedBy   = "Terraform"
      Region      = "ap-southeast-4"
    }
  }
}

# Additional variables needed for provider configuration
variable "workload_account_role_arn" {
  description = "ARN of the IAM role to assume in the workload account"
  type        = string
}

variable "transit_account_role_arn" {
  description = "ARN of the IAM role to assume in the transit account"
  type        = string
}