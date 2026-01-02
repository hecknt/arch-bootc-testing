#!/bin/bash

set -exuo pipefail

# Install bootc & uupd
pacman -R --noconfirm bootc
pacman -S --noconfirm \
  bootc-testing/bootc-git \
  bootc/uupd

systemctl enable uupd.timer

# Rebuild initramfs after bootc install
dracut --force --verbose "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)/initramfs.img"
