variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "test-vpc"
}

variable "vsi_name" {
  description = "VSI Name"
  type        = string
  default     = ""
}

variable "create_vpc" {
  type    = bool
  default = false
}

variable "existing_vpc_id" {
  description = "Existing VPC ID"
  type        = string
  default     = ""
}

variable "rhel_image" {
  description = "RHEL Image ID"
  type        = string
  default     = ""
}

variable "workstation_public_ip" {
  description = "Public IP of your workstation in CIDR notation"
  type        = string
  default     = ""
}

variable "ssh_private_key" {
  description = "SSH Private Key"
  type        = string
  default     = ""
}