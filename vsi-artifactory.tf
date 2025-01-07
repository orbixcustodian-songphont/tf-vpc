resource "ibm_is_volume" "artifactory-vsi-vol" {
  name     = "${var.artifactory_vsi_name}-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 250               # in GB
  zone     = "jp-tok-3"        # adjust to match your region/zone
}

resource ibm_is_instance artifactory-vsi {
  name    = var.artifactory_vsi_name
  profile = "bx2-4x16"
  image   = "r022-d5e7a447-981e-4ffe-906e-1ff648690bf9"
  zone    = "jp-tok-3"
  vpc     = ibm_is_vpc.vpc[0].id
  depends_on = [ ibm_is_ssh_key.ssh-key ]
  
  # Attach primary network interface
  primary_network_interface {
    subnet = ibm_is_subnet.subnet_c.id
  }

  # Add SSH key
  keys = [
    ibm_is_ssh_key.ssh-key.id
  ]

  user_data = <<-EOT
    #!/bin/bash
    # Update system
    sudo dnf update -y

    # Install prerequisites
    sudo dnf install -y java-11-openjdk wget curl

    # Decode and save the SSH private key
    echo '${var.ssh_private_key}' | base64 --decode > /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa

    # Prepare and mount the volume
    sudo mkfs.ext4 /dev/vdd
    sudo mkdir -p /var/opt/jfrog/artifactory
    sudo mount /dev/vdd /var/opt/jfrog/artifactory
    echo '/dev/vdd /var/opt/jfrog/artifactory ext4 defaults 0 0' | sudo tee -a /etc/fstab

    # Adjust permissions
    sudo chown -R artifactory:artifactory /var/opt/jfrog/artifactory

    # Add JFrog GPG key and repository
    sudo rpm --import https://releases.jfrog.io/artifactory/api/gpg/key/public
    sudo tee /etc/yum.repos.d/jfrog.repo <<-EOF
    [jfrog]
    name=JFrog
    baseurl=https://releases.jfrog.io/artifactory/artifactory-rpms
    enabled=1
    gpgcheck=1
    gpgkey=https://releases.jfrog.io/artifactory/api/gpg/key/public
    EOF

    # Install Artifactory OSS
    sudo dnf install -y jfrog-artifactory-oss

    # Start and enable Artifactory
    sudo systemctl start artifactory
    sudo systemctl enable artifactory
  EOT
}

resource "ibm_is_instance_volume_attachment" "artifactory-vol-attach" {
  instance                         = ibm_is_instance.artifactory-vsi.id
  volume                           = ibm_is_volume.artifactory-vsi-vol.id
  delete_volume_on_instance_delete = true
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