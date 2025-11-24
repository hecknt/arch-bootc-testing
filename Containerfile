FROM docker.io/archlinux/archlinux:latest
COPY system_files /

ENV DRACUT_NO_XATTR=1

# Move /var/lib/pacman, /var/log/pacman.log, and /var/cache/pacman to /usr/lib/sysimage. 
# The rest of this process is handled in system_files/etc/pacman.conf
RUN mkdir -p /usr/lib/sysimage/{lib,cache,log} && \
  mv /var/lib/pacman /usr/lib/sysimage/lib/pacman && \
  mv /var/cache/pacman /usr/lib/sysimage/cache/pacman && \
  mv /var/log/pacman.log /usr/lib/sysimage/log/pacman.log

# Add Chaotic AUR repo
RUN pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
RUN pacman-key --init && pacman-key --lsign-key 3056513887B78AEB
RUN pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
RUN pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
RUN echo -e '[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf

# Add bootc repo
RUN pacman-key --recv-key 5DE6BF3EBC86402E7A5C5D241FA48C960F9604CB --keyserver keyserver.ubuntu.com
RUN pacman-key --lsign-key 5DE6BF3EBC86402E7A5C5D241FA48C960F9604CB
RUN echo -e '[bootc]\nSigLevel = Required\nServer=https://github.com/hecknt/arch-bootc-pkgs/releases/download/$repo' >> /etc/pacman.conf
# Add bootc-testing repo
RUN echo -e '[bootc-testing]\nSigLevel = Required\nServer=https://github.com/hecknt/arch-bootc-pkgs/releases/download/$repo' >> /etc/pacman.conf

# Refresh & upgrade all packages before we get started.
RUN pacman -Syu --noconfirm

# Base packages. The bare essentials.
RUN pacman -S --noconfirm \
  base \
  base-devel \
  dracut \
  linux-zen \
  linux-firmware \
  networkmanager \
  ostree \
  btrfs-progs \
  e2fsprogs \
  xfsprogs \
  dosfstools \
  skopeo \
  dbus \
  dbus-glib \
  glib2 \
  strace \
  glibc-locales \
  plymouth \
  shadow

# Replace iptables with iptables-nft
RUN yes | pacman -S iptables-nft

# Command Line utilities / shells
RUN pacman -S --noconfirm \
  arch-install-scripts \
  fastfetch \
  git \
  cryfs \
  rust \
  lsof \
  wget \
  curl \
  jq \
  less \
  just \
  openssh \
  man-db \
  powertop \
  tree \
  usbutils \
  tar \
  whois \
  7zip \
  unrar \
  unzip \
  yt-dlp \
  figlet \
  lolcat \
  cowsay \
  iperf3 \
  nmap \
  ripgrep \
  lsd \
  neovim \
  nano \
  micro \
  btop \
  htop \
  nvtop \
  python-pipx \
  bash-completion \
  nushell \
  zsh \
  zsh-completions

# Desktop Section
## Drivers
RUN pacman -S --noconfirm \
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
  lib32-vulkan-icd-loader \
  lib32-vulkan-intel \
  lib32-vulkan-radeon \
  lib32-mesa \
  clinfo

## Pipewire
RUN pacman -S --noconfirm \
  pipewire \
  pipewire-pulse \
  pipewire-zeroconf \
  pipewire-ffado \
  pipewire-libcamera \
  sof-firmware \
  wireplumber

## Theming
RUN pacman -S --noconfirm \
  adw-gtk-theme \
  nwg-look \
  chaotic-aur/qt6ct-kde \
  qt5ct

## Desktop Environment (Dank)
RUN pacman -S --noconfirm \
  niri \
  xwayland-satellite \
  hyprland \
  chaotic-aur/grimblast-git \
  chaotic-aur/dms-shell-git \
  brightnessctl \
  cava \
  wl-clipboard \
  gammastep \
  appstream-glib \
  gnome-keyring \
  cliphist \
  dgop \
  quickshell \
  kitty \
  ghostty \
  sxiv \
  mpv \
  fprintd \
  wev \
  ddcutil \
  ydotool

## Fonts
RUN pacman -S --noconfirm \
  ttf-jetbrains-mono \
  ttf-fira-code \
  ttf-ibm-plex \
  ttf-jetbrains-mono-nerd \
  ttf-firacode-nerd \
  otf-font-awesome \
  noto-fonts \
  noto-fonts-cjk \
  noto-fonts-emoji \
  noto-fonts-extra

## XDG desktop portals
RUN pacman -S --noconfirm \
  xdg-desktop-portal-gnome \
  xdg-desktop-portal-gtk

## Games! Steam! Games!
RUN pacman -S --noconfirm \
  steam \
  gamescope \
  umu-launcher \
  wine \
  winetricks \
  mangohud

# Non-system level packages! distrobox, toolbox, flatpak... etc. Also podman and docker. And LXC.
RUN pacman -S --noconfirm \
  podman \
  docker \
  distrobox \
  toolbox \
  bootc/podman-tui \
  podman-compose \
  docker-compose \
  bootc/bcvk \
  docker-buildx \
  chaotic-aur/flatpak-git \
  flatpak-builder \
  lxc \
  incus \
  incus-tools

# ADB, Virtualization, Building tools...
RUN pacman -S --noconfirm \
  android-tools \
  android-udev \
  libvirt \
  qemu-desktop \
  edk2-ovmf \
  guestfs-tools \
  virt-manager \
  pnpm \
  bpftop \
  bpftrace \
  --assume-installed vim # we have neovim, we don't need vim

# Enable systemd services
RUN systemctl enable \
  NetworkManager.service \
  systemd-sysusers.service \
  systemd-resolved.service
RUN systemctl enable --global \
  dms.service \
  gnome-keyring-daemon.service \
  gnome-keyring-daemon.socket

# Link neovim to vi and vim binaries
RUN ln -s ./nvim /usr/bin/vim && \
  ln -s ./nvim /usr/bin/vi

# Add wheel group to sudoers file
RUN echo "%wheel      ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers

# Install bootc and bootupd (bootloader updater)
RUN pacman -S --noconfirm \
  bootc-testing/bootc-git \
  bootc/bootupd

# Rebuild initramfs after bootc install
RUN dracut --force --verbose "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)/initramfs.img"

# Necessary for general behavior expected by image-based systems
RUN sed -i 's|^HOME=.*|HOME=/var/home|' "/etc/default/useradd" && \
  rm -rf /boot /home /root /usr/local /srv /mnt && \
  mkdir -p /var /sysroot /boot /usr/lib/ostree && \
  ln -s var/opt /opt && \
  ln -s var/roothome /root && \
  ln -s var/home /home && \
  ln -s var/mnt /mnt && \
  ln -s sysroot/ostree /ostree

# Cleanup pacman directories after installation
RUN rm -rf /usr/lib/sysimage/log /usr/lib/sysimage/cache/pacman/pkg

# Setup a temporary root passwd (1234) for dev purposes
# RUN usermod -p "$(echo "1234" | mkpasswd -s)" root

RUN bootc container lint --no-truncate
