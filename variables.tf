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

variable vsi_name {
  description = "VSI Name"
  type        = string
  default     = ""
}