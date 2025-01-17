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
  vpc        = ibm_is_vpc.vpc[0].id
  resource_group = data.ibm_resource_group.resource-group-name.id
  depends_on = [
    ibm_is_ssh_key.ssh-key, 
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
    subnet = ibm_is_subnet.subnet_a.id
  }

  # Add SSH key
  keys = [
    ibm_is_ssh_key.ssh-key.id
  ]
}


# resource "null_resource" "provision_artifactory" {
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

#   provisioner "remote-exec" {
#     inline = [
#       "dnf update -y",
#       "dnf upgrade -y",
#       "dnf install -y cloud-utils-growpart xfsprogs",
#       "mkdir -p /home && mkdir -p /tmp && mkdir -p /var && mkdir -p /var/log && mkdir -p /var/log/audit && mkdir -p /var/tmp",
#       "parted /dev/vdd mklabel gpt",
#       "parted /dev/vdd mkpart primary ext4 20481MiB 22529MiB",
#       "parted /dev/vdd mkpart primary ext4 22529MiB 24577MiB",
#       "parted /dev/vdd mkpart primary ext4 24577MiB 26625MiB",
#       "parted /dev/vdd mkpart primary ext4 26625MiB 28673MiB",
#       "parted /dev/vdd mkpart primary ext4 28673MiB 30721MiB",
#       "parted /dev/vdd mkpart primary ext4 30721MiB 32769MiB",
#       "parted /dev/vdd mkpart primary ext4 32769MiB 34817MiB",
#       "mkfs.ext4 /dev/vdd1",
#       "mkfs.ext4 /dev/vdd2",
#       "mkfs.ext4 /dev/vdd3",
#       "mkfs.ext4 /dev/vdd4",
#       "mkfs.ext4 /dev/vdd5",
#       "mkfs.ext4 /dev/vdd6",
#       "mkfs.ext4 /dev/vdd7",
#       "echo '/dev/vdd1 /home ext4 defaults,nodev 0 2' >> /etc/fstab",
#       "echo '/dev/vdd2 /tmp ext4 defaults 0 2' >> /etc/fstab",
#       "echo '/dev/vdd3 /var ext4 defaults 0 2' >> /etc/fstab",
#       "echo '/dev/vdd4 /var/log ext4 defaults 0 2' >> /etc/fstab",
#       "echo '/dev/vdd5 /var/log/audit ext4 defaults 0 2' >> /etc/fstab",
#       "echo '/dev/vdd6 /var/tmp ext4 defaults,nodev,nosuid,noexec 0 2' >> /etc/fstab",
#       "echo 'tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 2' >> /etc/fstab",
#       "mount -a",
#     ]
#   }
# }


resource "ibm_is_instance_volume_attachment" "rhel-home-attach" {
  instance                         = ibm_is_instance.rhel-vsi.id
  volume                           = ibm_is_volume.rhel-vsi-vol.id
  delete_volume_on_instance_delete = true
}
