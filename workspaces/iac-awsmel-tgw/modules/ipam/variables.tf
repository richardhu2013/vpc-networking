variable "name" {
  description = "Name of the IPAM"
  type        = string
}

variable "description" {
  description = "Description of the IPAM"
  type        = string
  default     = "IPAM for Melbourne region deployment"
}

variable "primary_region" {
  description = "Primary region for the IPAM"
  type        = string
  default     = "ap-southeast-4"
}

variable "additional_regions" {
  description = "Additional regions to include in the IPAM"
  type        = list(string)
  default     = []
}

variable "address_family" {
  description = "Address family for the IPAM pools"
  type        = string
  default     = "ipv4"
}

variable "top_level_cidr" {
  description = "CIDR for the top-level IPAM pool"
  type        = string
}

variable "regional_cidr" {
  description = "CIDR for the regional IPAM pool"
  type        = string
}

variable "functional_pools" {
  description = "Map of functional pools to create with their CIDRs"
  type = map(object({
    cidr        = string
    description = optional(string)
  }))
}

variable "enable_ram_sharing" {
  description = "Whether to share the IPAM pools using Resource Access Manager"
  type        = bool
  default     = false
}

variable "allow_external_principals" {
  description = "Whether to allow external principals in RAM sharing"
  type        = bool
  default     = false
}

variable "principal_account_ids" {
  description = "List of AWS account IDs to share the IPAM pools with"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}