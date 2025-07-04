variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-4"
}

# Transit Gateway Variables
variable "transit_gateway_name" {
  description = "Name of the Transit Gateway"
  type        = string
  default     = "de-poc-tgw"
}

variable "transit_gateway_description" {
  description = "Description of the Transit Gateway"
  type        = string
  default     = "Transit Gateway for Melbourne region"
}

variable "transit_gateway_asn" {
  description = "ASN for the Transit Gateway"
  type        = number
  default     = 64512
}

variable "enable_dx_gateway" {
  description = "Whether to create and attach a Direct Connect Gateway"
  type        = bool
  default     = true
}

variable "dx_amazon_side_asn" {
  description = "ASN for the Direct Connect Gateway"
  type        = number
  default     = 64513
}

variable "dx_allowed_prefixes" {
  description = "List of CIDR blocks allowed to be advertised through the Direct Connect Gateway"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

variable "security_vpc_attachment_id" {
  description = "ID of the Security VPC attachment (for default routes)"
  type        = string
  default     = ""
}

# RAM Sharing Variables
variable "enable_ram_sharing" {
  description = "Whether to share the Transit Gateway using Resource Access Manager"
  type        = bool
  default     = false
}

variable "allow_external_principals" {
  description = "Whether to allow external principals in RAM sharing"
  type        = bool
  default     = false
}

variable "principal_account_ids" {
  description = "List of AWS account IDs to share resources with"
  type        = list(string)
  default     = []
}

# IPAM Variables
variable "ipam_name" {
  description = "Name of the IPAM"
  type        = string
  default     = "de-vic-ipam"
}

variable "ipam_description" {
  description = "Description of the IPAM"
  type        = string
  default     = "IPAM for Department of Education Victoria Melbourne region"
}

variable "ipam_additional_regions" {
  description = "Additional regions to include in the IPAM"
  type        = list(string)
  default     = ["ap-southeast-4"]  # Sydney region
}

variable "ipam_top_level_cidr" {
  description = "CIDR for the top-level IPAM pool"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ipam_regional_cidr" {
  description = "CIDR for the regional IPAM pool"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ipam_functional_pools" {
  description = "Map of functional pools to create with their CIDRs"
  type = map(object({
    cidr = string
    description = optional(string)
  }))
  default = {
    security = {
      cidr        = "10.0.0.0/23"
      description = "Pool for Security VPC"
    },
    external-lb = {
      cidr        = "10.0.2.0/23"
      description = "Pool for External LB VPC"
    },
    internal-lb = {
      cidr        = "10.0.6.0/23"
      description = "Pool for Internal LB VPC"
    },
    workload = {
      cidr        = "10.0.16.0/20"
      description = "Pool for Workload VPCs"
    },
    cisco = {
      cidr        = "10.0.32.0/20"
      description = "Pool for Cisco VPCs"
    }
  }
}

variable "enable_ipam_ram_sharing" {
  description = "Whether to share IPAM pools using Resource Access Manager"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    Environment = "Production"
    Project     = "DOEVic-Melbourne"
    ManagedBy   = "Terraform"
  }
}