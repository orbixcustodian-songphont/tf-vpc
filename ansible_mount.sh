#!/bin/bash

# Update and upgrade packages
dnf update -y
dnf upgrade -y

# Install necessary packages
dnf install -y cloud-utils-growpart xfsprogs

# create the directories
mkdir -p /home && mkdir -p /tmp && mkdir -p /var && mkdir -p /var/log && mkdir -p /var/log/audit && mkdir -p /var/tmp

# Partition the disk
parted /dev/vdd mklabel gpt
parted /dev/vdd mkpart primary ext4 1MiB 1025MiB
parted /dev/vdd mkpart primary ext4 1025MiB 2049MiB
parted /dev/vdd mkpart primary ext4 2049MiB 3073MiB
parted /dev/vdd mkpart primary ext4 3073MiB 4097MiB
parted /dev/vdd mkpart primary ext4 4097MiB 5121MiB
parted /dev/vdd mkpart primary ext4 5121MiB 6145MiB

# Format the partitions
mkfs.ext4 /dev/vdd1
mkfs.ext4 /dev/vdd2
mkfs.ext4 /dev/vdd3
mkfs.ext4 /dev/vdd4
mkfs.ext4 /dev/vdd5
mkfs.ext4 /dev/vdd6

# Update /etc/fstab
echo '/dev/vdd1 /home ext4 defaults,nodev 0 2' >> /etc/fstab
echo '/dev/vdd2 /tmp ext4 defaults 0 2' >> /etc/fstab
echo '/dev/vdd3 /var ext4 defaults 0 2' >> /etc/fstab
echo '/dev/vdd4 /var/log ext4 defaults 0 2' >> /etc/fstab
echo '/dev/vdd5 /var/log/audit ext4 defaults 0 2' >> /etc/fstab
echo '/dev/vdd6 /var/tmp ext4 defaults,nodev,nosuid,noexec 0 2' >> /etc/fstab
echo 'tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 2' >> /etc/fstab

# Mount all filesystems
mount -a
