# Create VPC
resource "ibm_is_vpc" "vpc" {
  name = var.vpc_name
}

output "vpc_id" {
  value = ibm_is_vpc.vpc.id
}

output "public_gateway_ids" {
  value = [
    ibm_is_public_gateway.public_gateway_a.id,
    ibm_is_public_gateway.public_gateway_b.id,
    ibm_is_public_gateway.public_gateway_c.id
  ]
}

output "subnet_ids" {
  value = [
    ibm_is_subnet.subnet_a.id,
    ibm_is_subnet.subnet_b.id,
    ibm_is_subnet.subnet_c.id
  ]
}
output "existing_keys" {
  value = data.ibm_is_ssh_keys.existing_keys.keys
}

output "vsi" {
  value = ibm_is_instance.test-vsi
}