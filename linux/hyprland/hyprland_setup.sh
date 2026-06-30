#!/bin/bash
set -euo pipefail

sudo -v

# install base deps
sudo pacman -S --needed --noconfirm base-devel git curl wget rsync

# repos directory
REPOS_DIR="$HOME/Repos"
mkdir -p "$REPOS_DIR"
cd "$REPOS_DIR"

# install paru
if ! command -v paru &>/dev/null; then
  if [ ! -d paru ]; then
    git clone https://aur.archlinux.org/paru.git
  fi
  (
    cd paru
    makepkg -si --noconfirm --needed
  )
fi

# install hyprland must-haves
sudo pacman -S --needed --noconfirm \
  dunst pipewire hyprpolkitagent qt6-wayland qt5-wayland \
  noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

paru -S --needed --noconfirm --skipreview ashell

# copy config files (linux only)
CONFIG_SRC="$REPOS_DIR/dev-env/linux/config/"
CONFIG_DST="$HOME/.config/"
mkdir -p "$CONFIG_DST"
rsync -av "$CONFIG_SRC" "$CONFIG_DST"
rsync -av "$REPO_DIR/dev-env/shared/ghostty" "$CONFIG_DST"

# reload hyprland
hyprctl reload

# install my shit
sudo pacman -S --needed --noconfirm \
	ghostty vlc qbittorrent code nautilus \
	nwg-look dconf

paru -S --needed --noconfirm --skipreview brave-bin

# Set GTK theme to dark
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
