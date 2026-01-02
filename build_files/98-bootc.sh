#!/bin/bash

set -exuo pipefail

# Install bootc & uupd
pacman -S --noconfirm \
  bootc-testing/bootc-git \
  bootc/uupd

systemctl enable uupd.timer

# Rebuild initramfs after bootc install
dracut --force --verbose "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)/initramfs.img"

# Necessary for general behavior expected by image-based systems
sed -i 's|^HOME=.*|HOME=/var/home|' "/etc/default/useradd" && \
  rm -rf /boot /home /root /usr/local /srv /mnt /var && \
  mkdir -p /var /sysroot /boot /usr/lib/ostree && \
  ln -s var/opt /opt && \
  ln -s var/roothome /root && \
  ln -s var/home /home && \
  ln -s var/srv /srv && \
  ln -s var/mnt /mnt && \
  ln -s sysroot/ostree /ostree
