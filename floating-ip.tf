resource "ibm_is_floating_ip" "fip1" {
  name = "${var.vpc_name}-floating-ip"
  zone = "jp-tok-1"
  resource_group = coalesce(data.ibm_resource_group.example.id,ibm_resource_group.example[0].id)
}