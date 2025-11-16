FROM docker.io/archlinux/archlinux:latest

ENV DRACUT_NO_XATTR=1

# Source for this codeblock: XeniaMeraki/XeniaOS
# Set it up such that pacman will automatically clean package cache after each install
# So that we don't run out of memory in image generation and don't need to append --clean after everything
RUN echo -e "[Trigger]\n\
  Operation = Install\n\
  Operation = Upgrade\n\
  Type = Package\n\
  Target = *\n\
  \n\
  [Action]\n\
  Description = Cleaning up package cache...\n\
  Depends = coreutils\n\
  When = PostTransaction\n\
  Exec = /usr/bin/rm -rf /var/cache/pacman/pkg" | tee /usr/share/libalpm/hooks/package-cleanup.hook

# Refresh & upgrade all packages before we get started.
RUN pacman -Syu --noconfirm

# Base packages. The bare essentials.
RUN pacman -S --noconfirm \
  base \
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
  shadow

# Command Line utilities / shells
RUN pacman -S --noconfirm \
  arch-install-scripts \
  fastfetch \
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
  nushell \
  zsh

# Non-system level packages! distrobox, toolbox, flatpak... etc. Also podman and docker.
RUN pacman -S --noconfirm \
  podman \
  docker \
  distrobox \
  toolbox \
  flatpak

# Enable systemd services
RUN systemctl enable \
  NetworkManager.service

# Regression with newer dracut broke this
RUN mkdir -p /etc/dracut.conf.d && \
  printf "systemdsystemconfdir=/etc/systemd/system\nsystemdsystemunitdir=/usr/lib/systemd/system\n" | tee /etc/dracut.conf.d/fix-bootc.conf

RUN --mount=type=tmpfs,dst=/tmp --mount=type=tmpfs,dst=/root \
  pacman -S --noconfirm base-devel git rust && \
  git clone "https://github.com/bootc-dev/bootc.git" /tmp/bootc && \
  make -C /tmp/bootc bin install-all install-initramfs-dracut && \
  sh -c 'export KERNEL_VERSION="$(basename "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)")" && \
  dracut --force --no-hostonly --reproducible --zstd --verbose --kver "$KERNEL_VERSION"  "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"'

# Necessary for general behavior expected by image-based systems
RUN sed -i 's|^HOME=.*|HOME=/var/home|' "/etc/default/useradd" && \
  rm -rf /boot /home /root /usr/local /srv && \
  mkdir -p /var /sysroot /boot /usr/lib/ostree && \
  ln -s var/opt /opt && \
  ln -s var/roothome /root && \
  ln -s var/home /home && \
  ln -s sysroot/ostree /ostree && \
  echo "$(for dir in opt usrlocal home srv mnt ; do echo "d /var/$dir 0755 root root -" ; done)" | tee -a /usr/lib/tmpfiles.d/bootc-base-dirs.conf && \
  echo "d /var/roothome 0700 root root -" | tee -a /usr/lib/tmpfiles.d/bootc-base-dirs.conf && \
  echo "d /run/media 0755 root root -" | tee -a /usr/lib/tmpfiles.d/bootc-base-dirs.conf && \
  printf "[composefs]\nenabled = yes\n[sysroot]\nreadonly = true\n" | tee "/usr/lib/ostree/prepare-root.conf"

# Setup a temporary root passwd (1234) for dev purposes
# RUN pacman -S whois --noconfirm
# RUN usermod -p "$(echo "1234" | mkpasswd -s)" root

RUN bootc container lint
