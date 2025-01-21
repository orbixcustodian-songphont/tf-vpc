resource "ibm_is_volume" "rhel-vsi-vol" {
  name     = "${var.rhel_image}-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 100               # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
  resource_group = data.ibm_resource_group.resource-group-name.id
}


resource "ibm_is_instance" "rhel-vsi" {
  name       = var.rhel_image
  profile    = "bx2-2x8"
  image      = local.rhel_image
  zone       = "jp-tok-1"
  vpc        = var.vpc-id_ansible-node
  resource_group = data.ibm_resource_group.resource-group-name.id
  depends_on = [
    ibm_is_volume.rhel-vsi-vol, 
  ]

  user_data = <<-EOT
  #cloud-config
  package_update: true
  package_upgrade: true
  packages:
    - cloud-utils-growpart
    - xfsprogs
  EOT

  # Attach primary network interface
  primary_network_interface {
    subnet = var.subnet_ansible-node
  }

  # Add SSH key
  keys = [
    var.ssh_ansible-node
  ]
}
resource "ibm_is_instance_volume_attachment" "rhel-home-attach" {
  instance                         = ibm_is_instance.rhel-vsi.id
  volume                           = ibm_is_volume.rhel-vsi-vol.id
  delete_volume_on_instance_delete = true
}
