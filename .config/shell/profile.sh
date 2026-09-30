#!/bin/sh

# path
export PATH="$VCPKG_ROOT:$PATH"      # vcpkg
export PATH="$HOME/.local/bin:$PATH" # uv

# colours for ls/eza/completion by file type
command -v vivid >/dev/null 2>&1 && export LS_COLORS="$(vivid generate gruvbox-dark)" # vivid themes | fzf --preview 'vivid preview {}'

# macos only
test -f "$XDG_CONFIG_HOME/shell/profile.macos.sh" && source "$XDG_CONFIG_HOME/shell/profile.macos.sh"
