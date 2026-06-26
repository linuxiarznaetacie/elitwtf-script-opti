#!/bin/bash

if grep -q "^#\[multilib\]" /etc/pacman.conf; then
    sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/s/^#//' /etc/pacman.conf
fi

sudo pacman -Syu --noconfirm

sudo pacman -S --needed --noconfirm \
    git wget curl htop flatpak discover gamemode mangohud \
    networkmanager plasma-nm pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber \
    zram-generator \
    alsa-utils gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav libdvdcss ffmpeg vlc \
    ttf-dejavu ttf-liberation ttf-opensans noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-hack-nerd

sudo ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
sudo hwclock --systohc

echo -e "[zram0]\nzram-size = ram / 2" | sudo tee /etc/systemd/zram-generator.conf
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0

if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay-bin
fi

yay -S --needed --noconfirm ttf-ms-fonts

fc-cache -fv

if command -v balooctl6 &> /dev/null; then
    balooctl6 disable
elif command -v balooctl &> /dev/null; then
    balooctl disable
fi

sudo sysctl -w vm.vfs_cache_pressure=50
sudo sysctl -w vm.swappiness=10
echo -e "vm.vfs_cache_pressure=50\nvm.swappiness=10" | sudo tee /etc/sysctl.d/99-sysctl.conf

qdbus6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logout 2>/dev/null || qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout
sleep 2
plasmashell &>/dev/null &
