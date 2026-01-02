#!/bin/bash

set -xeuo pipefail

## Fonts
pacman -S --noconfirm \
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
