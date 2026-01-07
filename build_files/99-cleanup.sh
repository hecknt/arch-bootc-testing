#!/bin/bash

set -xeuo pipefail

# Cleanup pacman directories after installation
rm -rf /usr/lib/sysimage/log /usr/lib/sysimage/cache/pacman/pkg

# bootc
rm -rf /boot /var
mkdir -p /boot /var

# Remove /etc/resolv.conf, we use tmpfiles.d to link it to /run/systemd/resolve/resolv.conf
rm -f /etc/resolv.conf
