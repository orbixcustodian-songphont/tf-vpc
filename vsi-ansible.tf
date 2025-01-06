resource ibm_is_instance ansible-vsi {
  name    = var.vsi_name
  profile = "bx2-2x8"
  image   = "r022-d5e7a447-981e-4ffe-906e-1ff648690bf9"
  zone    = "jp-tok-1"
  vpc     = ibm_is_vpc.vpc[0].id
  depends_on = [ ibm_is_ssh_key.orbix_key, ibm_is_volume.home-vol ]
  
  # Attach primary network interface
  primary_network_interface {
    subnet = ibm_is_subnet.subnet_a.id
  }

  # Add SSH key
  keys = [
    ibm_is_ssh_key.orbix_key.id
  ]

  user_data = <<-EOT
#cloud-config
package_update: true
packages:
  - ansible-core
runcmd:
  - [ "/bin/bash", "-c", "set -e && dnf update -y && dnf install git ansible-core -y && ansible-galaxy collection install community.general ansible.posix" ]
EOT
}

resource "ibm_is_virtual_network_interface" "is-vni-vsi" {
  allow_ip_spoofing = true
  auto_delete = false
  enable_infrastructure_nat = true
  name = "test-vni"
  subnet = ibm_is_subnet.subnet_a.id
}

resource "ibm_is_instance_network_interface_floating_ip" "vni-test" {
  instance          = ibm_is_instance.ansible-vsi.id
  network_interface = ibm_is_instance.ansible-vsi.primary_network_interface[0].id
  floating_ip       = ibm_is_floating_ip.fip1.id
}