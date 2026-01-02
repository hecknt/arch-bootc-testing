#!/bin/bash

set -xeu

# Add Chaotic AUR repo
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
echo -e '[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf

# Add bootc-testing repo
echo -e '[bootc-testing]\nSigLevel = Required\nServer=https://github.com/hecknt/arch-bootc-pkgs/releases/download/$repo' >> /etc/pacman.conf
# Add danklinux repo
echo -e '[danklinux]\nSigLevel = Required\nServer=https://github.com/hecknt/arch-danklinux-pkgs/releases/download/$repo' >> /etc/pacman.conf

# Refresh & upgrade all packages before we get started.
pacman -Syu --noconfirm

# Remove kernel from base image and any existing modules
pacman -Rns --noconfirm linux
rm -rf /usr/lib/modules

# Base packages. The bare essentials.
pacman -S --noconfirm --needed \
  base-devel \
  linux-zen \
  glibc-locales \
  plymouth

# Replace iptables with iptables-nft
yes | pacman -S iptables-nft

# Command Line utilities / shells
pacman -S --noconfirm \
  arch-install-scripts \
  fastfetch \
  chezmoi \
  git \
  cryfs \
  rust \
  lsof \
  bc \
  bat \
  fzf \
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
  dmidecode \
  yt-dlp \
  figlet \
  lolcat \
  cowsay \
  iperf3 \
  nmap \
  ripgrep \
  inetutils \
  power-profiles-daemon \
  jujutsu \
  lsd \
  neovim \
  nano \
  micro \
  strace \
  btop \
  htop \
  nvtop \
  python-pipx \
  starship \
  bash-completion \
  nushell \
  zsh \
  zsh-completions

# Link neovim to vi and vim binaries
ln -s ./nvim /usr/bin/vim
ln -s ./nvim /usr/bin/vi

# Add wheel group to sudoers file
echo "%wheel      ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers

# Enable systemd services
systemctl enable \
  sysusers.service \
  systemd-resolved.service \
  brew-setup.service
