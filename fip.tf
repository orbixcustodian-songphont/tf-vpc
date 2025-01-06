resource "ibm_is_floating_ip" "fip1" {
  name = "${var.vpc_name}-floating-ip"
  zone = "jp-tok-1"
}