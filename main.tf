# # Create VPC
# resource "ibm_is_vpc" "vpc" {
#   count = var.create_vpc && var.existing_vpc_id == "" ? 1 : 0
#   name  = var.vpc_name
#   resource_group = data.ibm_resource_group.resource-group-name.id
# }

# resource "ibm_is_security_group" "sg" {
#   name = "${var.vpc_name}-sg"
#   vpc  = local.vpc_id
#   resource_group = data.ibm_resource_group.resource-group-name.id
#   depends_on = [ ibm_is_vpc.vpc ]
# }

# resource "ibm_is_security_group_rule" "ssh" {
#   group =  ibm_is_security_group.sg.id
#   direction         = "inbound"
#   remote            = var.workstation_public_ip
#   local             = "0.0.0.0/0"
#   tcp {
#     port_min = 22
#     port_max = 22
#   }
# }

# resource "ibm_is_security_group_target" "sg_target" {
#   target = ibm_is_instance.ansible-vsi.primary_network_interface[0].id
#   security_group = ibm_is_security_group.sg.id
#   depends_on = [ ibm_is_security_group.sg, ibm_is_instance.ansible-vsi ]
# }

# output "vpc_id" {
#   value = local.vpc_id
# }

# output "public_gateway_ids" {
#   value = [
#     ibm_is_public_gateway.public_gateway_a.id,
#     ibm_is_public_gateway.public_gateway_b.id,
#     ibm_is_public_gateway.public_gateway_c.id
#   ]
# }

# output "subnet_ids" {
#   value = [
#     ibm_is_subnet.subnet_a.id,
#     ibm_is_subnet.subnet_b.id,
#     ibm_is_subnet.subnet_c.id
#   ]
# }

# output "vsi" {
#   value = [ ibm_is_instance.ansible-vsi, ibm_is_instance.rhel-vsi ]
# }