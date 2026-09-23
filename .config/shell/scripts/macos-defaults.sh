#!/bin/sh

if [ "$(uname)" != "Darwin" ]; then
  echo "Error: macos only" >&2
  exit 1
fi

if [ "$1" != "-y" ]; then
  echo "This will change macOS system settings (some steps need sudo)."
  printf 'Continue? [y/N] '
  read -r reply
  case $reply in
    [yY] | [yY][eE][sS]) ;;
    *) echo "Aborted." && exit 0 ;;
  esac
fi

set -e

# touchid sudo prompts rather than entering password (sudo_local survives macos updates)
if ! grep -qs '^auth.*pam_tid.so' /etc/pam.d/sudo_local; then
  echo 'auth       sufficient     pam_tid.so' | sudo tee /etc/pam.d/sudo_local >/dev/null
fi

# no startup chime
sudo nvram StartupMute=%01

# global
defaults write NSGlobalDomain AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 # cycle through ui buttons with tab
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain com.apple.sound.beep.feedback -int 1 # sound when changing volume

# dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock showhidden -bool true

# finder
defaults write com.apple.finder AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# control center (per-host pref)
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true

# dont create .DS_Store files on usb or network volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# disable personalized advertising
defaults write com.apple.AdLib forceLimitAdTracking -bool true
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false
defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false

# install rosetta
if ! pkgutil --pkgs | grep -q "com.apple.pkg.RosettaUpdateAuto"; then
  softwareupdate --install-rosetta --agree-to-license
fi

# disable 'slightly dim the display on battery'
sudo pmset -b lessbright 0

# apply without logging out
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
killall Dock Finder SystemUIServer ControlCenter 2>/dev/null || true

echo "Done. Some settings need a relaunch of apps (or a logout) to take effect."
