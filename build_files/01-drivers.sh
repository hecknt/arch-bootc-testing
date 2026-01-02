#!/bin/bash

set -xeuo pipefail

# Drivers
pacman -S --noconfirm \
  amd-ucode \
  intel-ucode \
  efibootmgr \
  shim \
  mesa \
  libva-intel-driver \
  libva-mesa-driver \
  vpl-gpu-rt \
  vulkan-icd-loader \
  vulkan-intel \
  vulkan-radeon \
  clinfo

# Bluetooth & internet
pacman -S --noconfirm \
  networkmanager \
  bluez \
  bluez-utils

# Pipewire
pacman -S --noconfirm \
  pipewire \
  pipewire-pulse \
  pipewire-zeroconf \
  pipewire-ffado \
  pipewire-libcamera \
  sof-firmware \
  wireplumber


# Enable systemd services
systemctl enable \
  bluetooth.service \
  NetworkManager.service
