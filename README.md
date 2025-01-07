# IBM VPC Gen 2 Terraform

## Overview
This Terraform configuration provisions a VPC in IBM Cloud with subnets, gateways, and compute instances
using the provided variables.

## Custom Variables
Below is a quick reference for the variables in `custom.tfvars`: (Note: all variables are required)

- `ibmcloud_api_key`: IBM Cloud API key with VPC permissions
- `vpc_name`: Name for your VPC
- `vsi_name`: Name for the VSI
- `rhel_image`: RHEL image name or ID
- `workstation_public_ip`: Your workstation’s public IP in CIDR format
- `create_vpc`: Set to true if you want Terraform to create a new VPC
- `existing_vpc_id`: Provide an existing VPC ID if not creating a new one
- `ssh_private_key`: SSH private key for accessing the VSI (Note: this needs to be base 64 encoded, and needs to be in the `.ssh/` folder of your repository)

Example:
```
ssh_private_key = base64encode(file("${path.module}/.ssh/id_rsa"))
```

## SSH Keys
It is recommended to generate your own SSH keys for the VPC that you will create.

```bash
# Navigate to the repository directory
cd repository_directory

# Create the .ssh directory if it doesn't exist
mkdir -p .ssh

# Generate the SSH key pair with RSA 4096
ssh-keygen -t rsa -b 4096 -f .ssh/id_rsa

# Set the correct permissions for the private key
chmod 600 .ssh/id_rsa
```

## Usage
1. Create a new variable file called `custom.tfvars`
1. Update the variables in `custom.tfvars` to match your environment.
1. Run:
   - `terraform init`
   - `terraform plan --var-file=custom.tfvars`
   - `terraform apply --var-file=custom.tfvars`
1. Wait for the resources to be provisioned in your IBM Cloud account.
