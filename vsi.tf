resource ibm_is_volume home-vol {
  name      = "home-vol-123"
  profile   = "general-purpose"    # or "5iops-tier", "10iops-tier", etc.
  capacity  = 10                   # in GB
  zone      = "jp-tok-1"        # adjust to match your region/zone
}

resource ibm_is_instance test-vsi {
  name    = var.vsi_name
  profile = "bx2-2x8"
  image   = "r022-d5e7a447-981e-4ffe-906e-1ff648690bf9"
  zone    = "jp-tok-1"
  vpc     = ibm_is_vpc.vpc.id
  
  # Attach primary network interface
  primary_network_interface {
    subnet = ibm_is_subnet.subnet_a.id
  }

  # Add SSH key
  keys = [
    for key in data.ibm_is_ssh_keys.existing_keys.keys : key.id if key.name == "orbix-vsi-ssh"
  ]
}

resource ibm_is_instance_volume_attachment vol-home-attach {
  instance = ibm_is_instance.test-vsi.id
  volume   = ibm_is_volume.home-vol.id

  # Setting this to true means the volume will be deleted
  # when you delete the VSI.
  delete_volume_on_instance_delete = true
}