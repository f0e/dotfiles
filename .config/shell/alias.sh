#!/bin/sh

alias ls='eza'
alias l='eza -lbF --git'
alias ll='eza -lbGF --git'
alias llm='eza -lbGd --git --sort=modified'
alias la='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale'
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale'
alias lS='eza -1'
alias lt='eza --tree --level=2'
alias l.='eza -a | grep -E "^\."'

# shared scripts in ~/.config/shell/scripts
alias macos-defaults='sh "$XDG_CONFIG_HOME/shell/scripts/macos-defaults.sh"'

# claudes
alias claude='echo "use claude-personal or claude-work" >&2; false'
alias claude-personal='CLAUDE_CONFIG_DIR="$HOME/.claude-personal" command claude'
alias claude-work='CLAUDE_CONFIG_DIR="$HOME/.claude-work" command claude'
