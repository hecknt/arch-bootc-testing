FROM docker.io/archlinux/archlinux:latest
COPY system_files /

ENV DRACUT_NO_XATTR=1

## Add Chaotic AUR repo
RUN pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
RUN pacman-key --init && pacman-key --lsign-key 3056513887B78AEB
RUN pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
RUN pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
RUN echo -e '[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf

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
  wev

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

# Non-system level packages! distrobox, toolbox, flatpak... etc. Also podman and docker.
RUN pacman -S --noconfirm \
  podman \
  docker \
  distrobox \
  toolbox \
  chaotic-aur/flatpak-git

# Enable systemd services
RUN systemctl enable \
  NetworkManager.service \
  systemd-resolved.service

RUN systemctl enable --global \
  dms.service \
  gnome-keyring-daemon.service \
  gnome-keyring-daemon.socket

# Create build user
RUN useradd -m --shell=/bin/bash build && usermod -L build && \
  echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
  echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install AUR packages
USER build
WORKDIR /home/build
RUN --mount=type=tmpfs,dst=/tmp \
  git clone https://aur.archlinux.org/paru-bin.git --single-branch /tmp/paru && \
  pushd /tmp/paru && \
  makepkg -si --noconfirm && \
  popd && \
  rm -drf /tmp/paru

RUN paru -S --noconfirm --removemake \
  aur/bootupd-git

USER root
WORKDIR /
# Cleanup, delete build user, and remove paru
RUN userdel -r build && \
  rm -drf /home/build && \
  sed -i '/build ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
  sed -i '/root ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers && \
  rm -rf /home/build && \
  rm -rf \
  /tmp/* \
  /var/cache/pacman/pkg/* && \
  pacman -Rns paru-bin

# Link neovim to vi and vim binaries
RUN ln -s ./nvim /usr/bin/vim && \
  ln -s ./nvim /usr/bin/vi

# Add wheel group to sudoers file
RUN echo "%wheel      ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers

RUN --mount=type=tmpfs,dst=/tmp --mount=type=tmpfs,dst=/root \
  git clone "https://github.com/frostyard/bootc.git" -b pr1779 /tmp/bootc && \
  make -C /tmp/bootc bin install-all && \
  sh -c 'export KERNEL_VERSION="$(basename "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)")" && \
  dracut --force --no-hostonly --reproducible --zstd --verbose --kver "$KERNEL_VERSION"  "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"'

# Necessary for general behavior expected by image-based systems
RUN sed -i 's|^HOME=.*|HOME=/var/home|' "/etc/default/useradd" && \
  rm -rf /boot /home /root /usr/local /srv /mnt && \
  mkdir -p /var /sysroot /boot /usr/lib/ostree && \
  ln -s var/opt /opt && \
  ln -s var/roothome /root && \
  ln -s var/home /home && \
  ln -s var/mnt /mnt && \
  ln -s sysroot/ostree /ostree

# The package list is located in /var/lib/pacman. By default, this won't be saved when we boot into the image. So:
RUN mv -v /var/lib/pacman /usr/lib/pacman && \
  systemctl enable var-lib-pacman.mount

# Setup a temporary root passwd (1234) for dev purposes
# RUN usermod -p "$(echo "1234" | mkpasswd -s)" root

RUN bootc container lint
