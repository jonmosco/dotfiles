#!/bin/bash
#
# MacOS Settings

# Set default location of screenshots
mkdir -p "${HOME}/Desktop/screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Desktop/screenshots"

# Set default name of screenshots
defaults write com.apple.screencapture name screen-shot

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles YES

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Start sshd
sudo systemsetup -setremotelogin on

# Empty Trash securely by default
defaults write com.apple.finder EmptyTrashSecurely -bool true
