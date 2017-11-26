#!/bin/bash
#
# MacOS Settings

# Set default location of screenshots
defaults write com.apple.screencapture location /Users/jmosco/Desktop/screenshots

# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles YES

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
