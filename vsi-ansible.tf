resource ibm_is_instance ansible-vsi {
  name    = var.vsi_name
  profile = "bx2-2x8"
  image   = local.rhel_image
  zone    = "jp-tok-1"
  vpc     = ibm_is_vpc.vpc[0].id
  resource_group = data.ibm_resource_group.resource-group-name.id
  depends_on = [ ibm_is_ssh_key.ssh-key ]
  
  # Attach primary network interface
  primary_network_interface {
    subnet = ibm_is_subnet.subnet_a.id
  }

  # Add SSH key
  keys = [
    ibm_is_ssh_key.ssh-key.id
  ]

  user_data = <<-EOT
  #cloud-config
  package_update: true
  package_upgrade: true
  packages:
    - ansible-core
  runcmd:
    - [ "/bin/bash", "-c", "set -e && dnf update -y && dnf install git ansible-core -y && ansible-galaxy collection install community.general ansible.posix" ]
    - [ "/bin/bash", "-c", "echo '${var.ssh_private_key}' | base64 decode > /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa" ]
    - [dnf, makecache]
    - [dnf, -y, upgrade]
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