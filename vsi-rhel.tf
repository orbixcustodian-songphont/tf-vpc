resource "ibm_is_volume" "rhel-home-vsi-vol" {
  name     = "rhel-home-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
}

resource "ibm_is_volume" "rhel-tmp-vsi-vol" {
  name     = "rhel-tmp-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
}

resource "ibm_is_volume" "rhel-var-vsi-vol" {
  name     = "rhel-var-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
}

resource "ibm_is_volume" "rhel-var-log-vsi-vol" {
  name     = "rhel-var-log-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
}

resource "ibm_is_volume" "rhel-var-log-audit-vsi-vol" {
  name     = "rhel-var-log-audit-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
}

resource "ibm_is_volume" "rhel-var-tmp-vsi-vol" {
  name     = "rhel-var-tmp-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
}

resource "ibm_is_volume" "rhel-dev-shm-audit-vsi-vol" {
  name     = "rhel-dev-shm-audit-vsi-vol"
  profile  = "general-purpose" # or "5iops-tier", "10iops-tier", etc.
  capacity = 10                # in GB
  zone     = "jp-tok-1"        # adjust to match your region/zone
}


resource "ibm_is_instance" "rhel-vsi" {
  name       = var.rhel_image
  profile    = "bx2-2x8"
  image      = "r022-d5e7a447-981e-4ffe-906e-1ff648690bf9"
  zone       = "jp-tok-1"
  vpc        = ibm_is_vpc.vpc[0].id
  depends_on = [
    ibm_is_ssh_key.orbix_key, 
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


#   user_data = <<-EOT
# #cloud-config
# # Cloud-init configuration for mounting block devices without loops

# runcmd:
#   - [ "/bin/bash", "-c", "DEVICE=/dev/vdd; MOUNT_POINT=/home; if [ -b $DEVICE ]; then \
#         mkdir -p $MOUNT_POINT; \
#         if ! blkid $DEVICE; then mkfs.xfs $DEVICE; fi; \
#         BACKUP_DIR=/tmp/home_backup; mkdir -p $BACKUP_DIR; rsync -a $MOUNT_POINT/ $BACKUP_DIR/; \
#         mount $DEVICE $MOUNT_POINT; \
#         UUID=$(blkid -s UUID -o value $DEVICE); \
#         echo \"UUID=$UUID $MOUNT_POINT xfs defaults 0 0\" >> /etc/fstab; fi" ]
#   - [ "/bin/bash", "-c", "DEVICE=/dev/vde; MOUNT_POINT=/var; if [ -b $DEVICE ]; then \
#         mkdir -p $MOUNT_POINT; \
#         if ! blkid $DEVICE; then mkfs.xfs $DEVICE; fi; \
#         BACKUP_DIR=/tmp/var_backup; mkdir -p $BACKUP_DIR; rsync -a $MOUNT_POINT/ $BACKUP_DIR/; \
#         mount $DEVICE $MOUNT_POINT; \
#         UUID=$(blkid -s UUID -o value $DEVICE); \
#         echo \"UUID=$UUID $MOUNT_POINT xfs defaults 0 0\" >> /etc/fstab; fi" ]
#   - [ "/bin/bash", "-c", "DEVICE=/dev/vdf; MOUNT_POINT=/tmp; if [ -b $DEVICE ]; then \
#         mkdir -p $MOUNT_POINT; \
#         if ! blkid $DEVICE; then mkfs.xfs $DEVICE; fi; \
#         BACKUP_DIR=/tmp/tmp_backup; mkdir -p $BACKUP_DIR; rsync -a $MOUNT_POINT/ $BACKUP_DIR/; \
#         mount $DEVICE $MOUNT_POINT; \
#         UUID=$(blkid -s UUID -o value $DEVICE); \
#         echo \"UUID=$UUID $MOUNT_POINT xfs defaults 0 0\" >> /etc/fstab; fi" ]
#   - [ "/bin/bash", "-c", "DEVICE=/dev/vdg; MOUNT_POINT=/var/log; if [ -b $DEVICE ]; then \
#         mkdir -p $MOUNT_POINT; \
#         if ! blkid $DEVICE; then mkfs.xfs $DEVICE; fi; \
#         BACKUP_DIR=/tmp/var_log_backup; mkdir -p $BACKUP_DIR; rsync -a $MOUNT_POINT/ $BACKUP_DIR/; \
#         mount $DEVICE $MOUNT_POINT; \
#         UUID=$(blkid -s UUID -o value $DEVICE); \
#         echo \"UUID=$UUID $MOUNT_POINT xfs defaults 0 0\" >> /etc/fstab; fi" ]
#   - [ "/bin/bash", "-c", "DEVICE=/dev/vdh; MOUNT_POINT=/var/log/audit; if [ -b $DEVICE ]; then \
#         mkdir -p $MOUNT_POINT; \
#         if ! blkid $DEVICE; then mkfs.xfs $DEVICE; fi; \
#         BACKUP_DIR=/tmp/var_log_audit_backup; mkdir -p $BACKUP_DIR; rsync -a $MOUNT_POINT/ $BACKUP_DIR/; \
#         mount $DEVICE $MOUNT_POINT; \
#         UUID=$(blkid -s UUID -o value $DEVICE); \
#         echo \"UUID=$UUID $MOUNT_POINT xfs defaults 0 0\" >> /etc/fstab; fi" ]
#   - [ "/bin/bash", "-c", "DEVICE=/dev/vdi; MOUNT_POINT=/var/tmp; if [ -b $DEVICE ]; then \
#         mkdir -p $MOUNT_POINT; \
#         if ! blkid $DEVICE; then mkfs.xfs $DEVICE; fi; \
#         BACKUP_DIR=/tmp/var_tmp_backup; mkdir -p $BACKUP_DIR; rsync -a $MOUNT_POINT/ $BACKUP_DIR/; \
#         mount $DEVICE $MOUNT_POINT; \
#         UUID=$(blkid -s UUID -o value $DEVICE); \
#         echo \"UUID=$UUID $MOUNT_POINT xfs defaults,nodev,nosuid,noexec 0 0\" >> /etc/fstab; fi" ]
#   - [ "/bin/bash", "-c", "DEVICE=/dev/vdj; MOUNT_POINT=/dev/shm; if [ -b $DEVICE ]; then \
#         mkdir -p $MOUNT_POINT; \
#         if ! blkid $DEVICE; then mkfs.xfs $DEVICE; fi; \
#         BACKUP_DIR=/tmp/dev_shm_backup; mkdir -p $BACKUP_DIR; rsync -a $MOUNT_POINT/ $BACKUP_DIR/; \
#         mount $DEVICE $MOUNT_POINT; \
#         UUID=$(blkid -s UUID -o value $DEVICE); \
#         echo \"UUID=$UUID $MOUNT_POINT xfs defaults,nodev,nosuid,noexec 0 0\" >> /etc/fstab; fi" ]
#   EOT

  # Add SSH key
  keys = [
    ibm_is_ssh_key.orbix_key.id
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

output "vsi_ip" {
    value = ibm_is_instance.rhel-vsi.primary_network_interface[0].primary_ipv4_address
}