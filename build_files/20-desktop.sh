#!/bin/bash

set -xeuo pipefail

# Theming
pacman -S --noconfirm \
  adw-gtk-theme \
  nwg-look \
  chaotic-aur/qt6ct-kde \
  qt5ct \
  libappimage

# XDG desktop portals
pacman -S --noconfirm \
  xdg-desktop-portal-gnome \
  xdg-desktop-portal-gtk \
  xdg-desktop-portal-kde && \
  rm -f /usr/share/wayland-sessions/plasma.desktop

# Desktop Environment (Dank)
pacman -S --noconfirm \
  niri \
  xwayland-satellite \
  danklinux/dms-shell \
  danklinux/greetd-dms-greeter \
  danklinux/quickshell-git \
  danklinux/dsearch \
  accountsservice \
  mate-polkit \
  brightnessctl \
  cava \
  wl-clipboard \
  gammastep \
  appstream-glib \
  gnome-keyring \
  cliphist \
  dgop \
  matugen \
  kitty \
  foot \
  sxiv \
  mpv \
  fprintd \
  wev \
  ddcutil \
  ydotool \
  dolphin \
  archlinux-xdg-menu \
  xdg-desktop-portal-kde \
  ark \
  udiskie

# Enable systemd services
systemctl enable \
  greetd.service
systemctl enable --global \
  dms.service \
  dsearch.service \
  gnome-keyring-daemon.service \
  gnome-keyring-daemon.socket \
  udiskie.service
