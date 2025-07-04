variable "name" {
  description = "Name of the Transit Gateway"
  type        = string
}

variable "description" {
  description = "Description of the Transit Gateway"
  type        = string
  default     = "Transit Gateway for the Melbourne region deployment"
}

variable "amazon_side_asn" {
  description = "Private ASN for the Amazon side of a BGP session"
  type        = number
  default     = 64512
}

variable "auto_accept_shared_attachments" {
  description = "Whether to automatically accept cross-account attachments"
  type        = string
  default     = "disable"
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support"
  type        = bool
  default     = true
}

variable "enable_vpn_ecmp_support" {
  description = "Whether to enable VPN ECMP support"
  type        = bool
  default     = true
}

variable "enable_dx_gateway" {
  description = "Whether to create and attach a Direct Connect Gateway"
  type        = bool
  default     = false
}

variable "dx_amazon_side_asn" {
  description = "ASN for the Direct Connect Gateway"
  type        = number
  default     = 64513
}

variable "dx_allowed_prefixes" {
  description = "List of CIDR blocks allowed to be advertised through the Direct Connect Gateway"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}