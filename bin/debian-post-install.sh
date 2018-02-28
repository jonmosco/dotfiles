#!/bin/bash
#
# Post debian install for thinkpad

# Base packages
apt-get update && apt-get install -y vim tmux htop git

# Wifi adapter
apt-get update && apt-get install firmware-iwlwifi
modprobe -r iwlwifi ; modprobe iwlwifi

# Google Apt key
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# Add to sources.list
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update && apt-get install google-chrome-stable
