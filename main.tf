# Create VPC
resource "ibm_is_vpc" "vpc" {
  count = var.create_vpc && var.existing_vpc_id == "" ? 1 : 0
  name  = var.vpc_name
}

output "vpc_id" {
  value = local.vpc_id
}

output "subnet_ids" {
  value = [
    ibm_is_subnet.subnet_a.id,
    ibm_is_subnet.subnet_b.id,
    ibm_is_subnet.subnet_c.id
  ]
}

output "vsi" {
  value = [ ibm_is_instance.ansible-vsi, ibm_is_instance.rhel-vsi ]
}