#!/bin/sh

# xdg base directory specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# use vscode as default editor (except in ssh)
export EDITOR="code --wait"
[ -n "$SSH_CONNECTION" ] && [ "$TERM_PROGRAM" != vscode ] && export EDITOR=nvim

# syntax highlighted man pages via bat
export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

# keep colours in less
export LESS='-R'

# disable et telemetry
export ET_NO_TELEMETRY=true

# don't add forgit aliases, i dont like them
# https://github.com/wfxr/forgit#shell-aliases
export FORGIT_NO_ALIASES=1

# vcpkg
export VCPKG_ROOT="$HOME/vcpkg"
