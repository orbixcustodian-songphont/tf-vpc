variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
  default     = ""
}

# variable "vpc_name" {
#   description = "VPC Name"
#   type        = string
#   default     = "test-vpc"
# }

# variable "vsi_name" {
#   description = "VSI Name"
#   type        = string
#   default     = ""
# }

# variable "vsi_openvpn_name" {
#   description = "VSI Name"
#   type        = string
#   default     = ""
# }

# variable "create_vpc" {
#   type    = bool
#   default = false
# }

# variable "existing_vpc_id" {
#   description = "Existing VPC ID"
#   type        = string
#   default     = ""
# }

# variable "rhel_image" {
#   description = "RHEL Image Name"
#   type        = string
#   default     = ""
# }

# variable "workstation_public_ip" {
#   description = "Public IP of your workstation in CIDR notation"
#   type        = string
#   default     = ""
# }

# variable "ssh_private_key" {
#   description = "SSH Private Key in Base64 format"
#   type        = string
#   default     = ""
# }

# variable "ssh_public_key" {
#   description = "SSH Public Key in plain text"
#   type        = string
#   default     = ""
# }

variable "resource_group" {
  description = "IBM Cloud Resource Group"
  type        = string
  default     = "Default"
}

variable "vpc-id_ansible-node" {
  description = "vpc id for ansible control node"
  type        = string
  default     = "r022-d07ab81f-8684-48b9-a8ef-0fc16118af94"
}

variable "subnet_ansible-node" {
  description = "vpc for ansible control node"
  type        = string
  default     = "02e7-5772c928-ed29-45c5-9405-e421827b211d"
}

variable "vpc-zone_ansible-node" {
  description = "vpc zone for ansible control node"
  type        = string
  default     = "jp-tok-1"
}

variable "ssh_ansible-node" {
  description = "ssh for ansible control node"
  type        = string
  default     = "r022-2d885420-69a2-45f9-b0e7-155cf682c2dd"
}

variable "vpc-id_rhel-node" {
  description = "vpc id for ansible control node"
  type        = string
  default     = "r022-d07ab81f-8684-48b9-a8ef-0fc16118af94"
}

variable "subnet_rhel-node" {
  description = "vpc for ansible control node"
  type        = string
  default     = "02e7-5772c928-ed29-45c5-9405-e421827b211d"
}

variable "vpc-zone_rhel-node" {
  description = "vpc zone for ansible control node"
  type        = string
  default     = "jp-tok-1"
}

variable "ssh_rhel-node" {
  description = "ssh for ansible control node"
  type        = string
  default     = "r022-2d885420-69a2-45f9-b0e7-155cf682c2dd"
}
