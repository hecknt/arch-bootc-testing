#!/bin/bash

set -xeuo pipefail

# Containers and stuff
pacman -S --noconfirm \
  podman \
  docker \
  distrobox \
  toolbox \
  podman-compose \
  docker-compose \
  bootc/bcvk \
  docker-buildx \
  chaotic-aur/flatpak-git \
  flatpak-builder \
  lxc \
  incus \
  incus-tools

# ADB
pacman -S --noconfirm \
  android-tools \
  android-udev \
  bpftop \
  bpftrace \
  --assume-installed vim # we have neovim, we don't need vim
