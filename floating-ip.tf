resource "ibm_is_floating_ip" "fip1" {
  name = "${var.vpc_name}-floating-ip"
  zone = "jp-tok-1"
  resource_group = data.ibm_resource_group.resource-group-name.id
}