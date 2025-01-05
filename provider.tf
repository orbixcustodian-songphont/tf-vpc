terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.50"
    }
  }
  required_version = ">= 1.3.0"
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region = "jp-tok"
}
