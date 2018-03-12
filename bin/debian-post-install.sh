#!/bin/bash
#
# Post debian install for thinkpad

packages=( nfs-common tmux htop git thinkfan )

# Update apt
apt-get update

# Base packages
for package in "${packages[@]}"; do
  apt-get install -y "${package}"
done

# Wifi adapter
apt-get update && apt-get install firmware-iwlwifi
modprobe -r iwlwifi ; modprobe iwlwifi

# Google Apt key
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# Add to sources.list
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update && apt-get install google-chrome-stable

# Gnome settings
gsettings set org.gnome.desktop.interface show-battery-percentage true
