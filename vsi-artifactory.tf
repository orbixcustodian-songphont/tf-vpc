resource "ibm_is_volume" "artifactory-vsi-vol" {
  name     = "${var.artifactory_vsi_name}-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 250               # in GB
  zone     = "jp-tok-3"        # adjust to match your region/zone
}

resource "ibm_is_instance" "artifactory-vsi" {
  name    = var.artifactory_vsi_name
  profile = "bx2-4x16"
  image   = local.rhel_image_id
  zone    = "jp-tok-3"
  vpc     = local.vpc_id
  depends_on = [ ibm_is_ssh_key.ssh-key, ibm_is_volume.artifactory-vsi-vol ]
  
  # Attach primary network interface
  primary_network_interface {
    subnet = ibm_is_subnet.subnet_c.id
  }

  # Add SSH key
  keys = [
    ibm_is_ssh_key.ssh-key.id
  ]
}

resource "null_resource" "provision_artifactory" {
  depends_on = [
    ibm_is_instance.artifactory-vsi, 
    ibm_is_instance_volume_attachment.artifactory-vol-attach
  ]

  connection {
    type        = "ssh"
    host        = ibm_is_floating_ip.fip3.address
    user        = "root"
    private_key = local.ssh_private_key_file_artifactory  
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y java-11-openjdk wget curl",
      "echo '${local.ssh_private_key_artifactory}' | base64 --decode > /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa",
      "echo '${local.ssh_public_key}' | base64 --decode > /root/.ssh/id_rsa.pub && chmod 600 /root/.ssh/id_rsa.pub",
      "sudo mkfs.ext4 /dev/vdd",
      "sudo mkdir -p /var/opt/jfrog/artifactory",
      "sudo mount /dev/vdd /var/opt/jfrog/artifactory",
      "echo '/dev/vdd /var/opt/jfrog/artifactory ext4 defaults 0 0' | sudo tee -a /etc/fstab",
      "sudo chown -R artifactory:artifactory /var/opt/jfrog/artifactory"
    ]
  }
}

resource "ibm_is_instance_volume_attachment" "artifactory-vol-attach" {
  instance                         = ibm_is_instance.artifactory-vsi.id
  volume                           = ibm_is_volume.artifactory-vsi-vol.id
  delete_volume_on_instance_delete = true
  depends_on = [ ibm_is_volume.artifactory-vsi-vol ]
}

resource "ibm_is_virtual_network_interface" "artifactory-vni-vsi" {
  allow_ip_spoofing = true
  auto_delete = false
  enable_infrastructure_nat = true
  name = "${var.artifactory_vsi_name}-vni"
  subnet = ibm_is_subnet.subnet_a.id
}

resource "ibm_is_instance_network_interface_floating_ip" "artifactory-vni-binding" {
  instance          = ibm_is_instance.artifactory-vsi.id
  network_interface = ibm_is_instance.artifactory-vsi.primary_network_interface[0].id
  floating_ip       = ibm_is_floating_ip.fip3.id
}

resource "ibm_is_security_group" "sg-artifactory" {
  name = "${var.vpc_name}-artifactory-sg"
  vpc  = local.vpc_id
  depends_on = [ ibm_is_vpc.vpc ]
}

resource "ibm_is_security_group_rule" "ssh-artifactory" {
  group =  ibm_is_security_group.sg-artifactory.id
  direction         = "inbound"
  remote            = var.workstation_public_ip
  local             = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "http" {
  group             = ibm_is_security_group.sg-artifactory.id
  direction         = "inbound"
  remote            = var.workstation_public_ip
  local             = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "https" {
  group             = ibm_is_security_group.sg-artifactory.id
  direction         = "inbound"
  remote            = var.workstation_public_ip
  local             = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "artifactory" {
  group             = ibm_is_security_group.sg-artifactory.id
  direction         = "inbound"
  remote            = var.workstation_public_ip
  local             = "0.0.0.0/0"
  tcp {
    port_min = 8046
    port_max = 8082
  }
}

resource "ibm_is_security_group_target" "artifactory_sg_target" {
  target         = ibm_is_instance.artifactory-vsi.primary_network_interface[0].id
  security_group = ibm_is_security_group.sg-artifactory.id
  depends_on     = [ ibm_is_security_group.sg-artifactory, ibm_is_instance.artifactory-vsi ]
}