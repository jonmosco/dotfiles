#!/bin/bash
#
# Post debian install for thinkpad

packages=( nfs-common tmux htop git thinkfan firmware-iwlwifi google-chrome-stable )
gnome_packages=( gnome-shell-extension-autohidetopbar )

# Wifi adapter
modprobe -r iwlwifi ; modprobe iwlwifi

# Google Apt key
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# Add to sources.list
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee -a /etc/apt/sources.list

# Final update and upgrade to ensure we have all the apt sources metadata
# Update and upgrade apt data
apt-get update && apt-get upgrade

# Base packages
for package in "${packages[@]}"; do
  apt-get install -y "${package}"
done

# Gnome settings
gsettings set org.gnome.desktop.interface show-battery-percentage true
