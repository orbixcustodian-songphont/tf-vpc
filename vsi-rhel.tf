resource "ibm_is_volume" "rhel-home-vsi-vol" {
  name     = "${var.rhel_image}-home-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
}

resource "ibm_is_volume" "rhel-tmp-vsi-vol" {
  name     = "${var.rhel_image}-tmp-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
}

resource "ibm_is_volume" "rhel-var-vsi-vol" {
  name     = "${var.rhel_image}-var-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
}

resource "ibm_is_volume" "rhel-var-log-vsi-vol" {
  name     = "${var.rhel_image}-var-log-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
}

resource "ibm_is_volume" "rhel-var-log-audit-vsi-vol" {
  name     = "${var.rhel_image}-var-log-audit-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
}

resource "ibm_is_volume" "rhel-var-tmp-vsi-vol" {
  name     = "${var.rhel_image}-var-tmp-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
}

resource "ibm_is_volume" "rhel-dev-shm-audit-vsi-vol" {
  name     = "${var.rhel_image}-dev-shm-audit-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
}


resource "ibm_is_instance" "rhel-vsi" {
  name       = var.rhel_image
  profile    = "bx2-2x8"
  image      = local.rhel_image_id
  zone       = "jp-tok-1"
  vpc        = local.vpc_id
  depends_on = [
    ibm_is_ssh_key.ssh-key, 
    ibm_is_volume.rhel-home-vsi-vol, 
    ibm_is_volume.rhel-tmp-vsi-vol, 
    ibm_is_volume.rhel-var-vsi-vol, 
    ibm_is_volume.rhel-var-log-vsi-vol, 
    ibm_is_volume.rhel-var-log-audit-vsi-vol, 
    ibm_is_volume.rhel-var-tmp-vsi-vol, 
    ibm_is_volume.rhel-dev-shm-audit-vsi-vol
  ]

  # Attach primary network interface
  primary_network_interface {
    subnet = ibm_is_subnet.subnet_a.id
  }

  # Add SSH key
  keys = [
    ibm_is_ssh_key.ssh-key.id
  ]
}

resource "ibm_is_instance_volume_attachment" "rhel-home-attach" {
  instance                         = ibm_is_instance.rhel-vsi.id
  volume                           = ibm_is_volume.rhel-home-vsi-vol.id
  delete_volume_on_instance_delete = true
}

resource "ibm_is_instance_volume_attachment" "rhel-tmp-attach" {
  instance                         = ibm_is_instance.rhel-vsi.id
  volume                           = ibm_is_volume.rhel-tmp-vsi-vol.id
  delete_volume_on_instance_delete = true
}

resource "ibm_is_instance_volume_attachment" "rhel-var-attach" {
  instance                         = ibm_is_instance.rhel-vsi.id
  volume                           = ibm_is_volume.rhel-var-vsi-vol.id
  delete_volume_on_instance_delete = true
}

resource "ibm_is_instance_volume_attachment" "rhel-var-log-attach" {
  instance                         = ibm_is_instance.rhel-vsi.id
  volume                           = ibm_is_volume.rhel-var-log-vsi-vol.id
  delete_volume_on_instance_delete = true
}

resource "ibm_is_instance_volume_attachment" "rhel-var-log-audit-attach" {
  instance                         = ibm_is_instance.rhel-vsi.id
  volume                           = ibm_is_volume.rhel-var-log-audit-vsi-vol.id
  delete_volume_on_instance_delete = true
}

resource "ibm_is_instance_volume_attachment" "rhel-var-tmp-attach" {
  instance                         = ibm_is_instance.rhel-vsi.id
  volume                           = ibm_is_volume.rhel-var-tmp-vsi-vol.id
  delete_volume_on_instance_delete = true
}

resource "ibm_is_instance_volume_attachment" "rhel-dev-shm-audit-attach" {
  instance                         = ibm_is_instance.rhel-vsi.id
  volume                           = ibm_is_volume.rhel-dev-shm-audit-vsi-vol.id
  delete_volume_on_instance_delete = true
}
