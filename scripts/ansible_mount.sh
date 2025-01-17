#!/usr/bin/env bash

# Update and upgrade packages
dnf update -y
dnf upgrade -y

# Install necessary packages
dnf install -y cloud-utils-growpart xfsprogs authselect

# configure authselect
var_authselect_profile='sssd'


authselect current

if test "$?" -ne 0; then
    authselect select "$var_authselect_profile"

    if test "$?" -ne 0; then
        if rpm --quiet --verify pam; then
            authselect select --force "$var_authselect_profile"
        else
	        echo "authselect is not used but files from the 'pam' package have been altered, so the authselect configuration won't be forced." >&2
        fi
    fi
fi

if [ -f /usr/bin/authselect ]; then
    if ! authselect check; then
echo "
authselect integrity check failed. Remediation aborted!
This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
It is not recommended to manually edit the PAM files when authselect tool is available.
In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
exit 1
fi
authselect enable-feature with-faillock

authselect apply-changes -b
else
    
AUTH_FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
for pam_file in "${AUTH_FILES[@]}"
do
    if ! grep -qE '^\s*auth\s+required\s+pam_faillock\.so\s+(preauth silent|authfail).*$' "$pam_file" ; then
        sed -i --follow-symlinks '/^auth.*sufficient.*pam_unix\.so.*/i auth        required      pam_faillock.so preauth silent' "$pam_file"
        sed -i --follow-symlinks '/^auth.*required.*pam_deny\.so.*/i auth        required      pam_faillock.so authfail' "$pam_file"
        sed -i --follow-symlinks '/^account.*required.*pam_unix\.so.*/i account     required      pam_faillock.so' "$pam_file"
    fi
    sed -Ei 's/(auth.*)(\[default=die\])(.*pam_faillock\.so)/\1required     \3/g' "$pam_file"
done

fi

if [ -f /usr/bin/authselect ]; then
    if ! authselect check; then
echo "
authselect integrity check failed. Remediation aborted!
This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
It is not recommended to manually edit the PAM files when authselect tool is available.
In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
exit 1
fi
authselect enable-feature with-faillock

authselect apply-changes -b
else
    
AUTH_FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
for pam_file in "${AUTH_FILES[@]}"
do
    if ! grep -qE '^\s*auth\s+required\s+pam_faillock\.so\s+(preauth silent|authfail).*$' "$pam_file" ; then
        sed -i --follow-symlinks '/^auth.*sufficient.*pam_unix\.so.*/i auth        required      pam_faillock.so preauth silent' "$pam_file"
        sed -i --follow-symlinks '/^auth.*required.*pam_deny\.so.*/i auth        required      pam_faillock.so authfail' "$pam_file"
        sed -i --follow-symlinks '/^account.*required.*pam_unix\.so.*/i account     required      pam_faillock.so' "$pam_file"
    fi
    sed -Ei 's/(auth.*)(\[default=die\])(.*pam_faillock\.so)/\1required     \3/g' "$pam_file"
done

fi

# create the directories
mkdir -p /home
mkdir -p /tmp
mkdir -p /var 
mkdir -p /var/log 
mkdir -p /var/log/audit
mkdir -p /var/tmp

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
