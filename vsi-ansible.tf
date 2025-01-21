resource ibm_is_instance ansible-vsi {
  name    = var.vsi_name
  profile = "bx2-2x8"
  image   = local.rhel_image
  zone    = "jp-tok-1"
  vpc     = var.vpc-id_ansible-node
  resource_group = data.ibm_resource_group.resource-group-name.id
  # depends_on = [ ibm_is_ssh_key.ssh-key ]
  
  # Attach primary network interface
  primary_network_interface {
    subnet = var.subnet_ansible-node
  }

  # Add SSH key
  keys = [
    var.ssh_ansible-node
  ]

  user_data = <<-EOT
  #cloud-config
  package_update: true
  package_upgrade: true
  packages:
    - ansible-core
  runcmd:
    - [ "/bin/bash", "-c", "set -e && dnf update -y && dnf install git ansible-core -y && ansible-galaxy collection install community.general ansible.posix" ]
    - [dnf, makecache]
    - [dnf, -y, upgrade]
EOT
}

resource "ibm_is_virtual_network_interface" "is-vni-vsi" {
  allow_ip_spoofing = true
  auto_delete = false
  enable_infrastructure_nat = true
  name = "ansible-vni"
  subnet = var.subnet_ansible-node
}

# resource "ibm_is_instance_network_interface_floating_ip" "vni-test" {
#   instance          = ibm_is_instance.ansible-vsi.id
#   network_interface = ibm_is_instance.ansible-vsi.primary_network_interface[0].id
#   floating_ip       = ibm_is_floating_ip.fip1.id
# }

resource "ibm_is_volume" "ansible-vsi-vol" {
  name     = "${var.vsi_name}-1-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
  resource_group = data.ibm_resource_group.resource-group-name.id
}

resource "ibm_is_instance_volume_attachment" "ansible-vol-attach" {
  instance                         = ibm_is_instance.ansible-vsi.id
  volume                           = ibm_is_volume.ansible-vsi-vol.id
  delete_volume_on_instance_delete = true
}

# resource "null_resource" "provision_rhel9_cis" {
#   depends_on = [
#     ibm_is_instance.rhel-vsi, 
#     ibm_is_instance_volume_attachment.rhel-home-attach
#   ]

#   connection {
#     type        = "ssh"
#     host        = ibm_is_floating_ip.fip1.address
#     user        = "root"
#     private_key = base64decode(var.ssh_private_key)  
#   }

#   provisioner "file" {
#     source      = "./scripts/rhel9-cis-level2-fix.sh"
#     destination = "/tmp/rhel9-cis-level2-fix.sh"
#   }

#   provisioner "file" {
#     source      = "./scripts/ansible_mount.sh"
#     destination = "/tmp/ansible_mount.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /tmp/rhel9-cis-level2-fix.sh",
#       "chmod +x /tmp/ansible_mount.sh",
#       "/tmp/ansible_mount.sh",
#       "/tmp/rhel9-cis-level2-fix.sh"
#     ]
#   }
# }
