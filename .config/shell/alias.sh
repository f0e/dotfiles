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

# macos only
test -f "$XDG_CONFIG_HOME/shell/alias.macos.sh" && source "$XDG_CONFIG_HOME/shell/alias.macos.sh"

# work-specific aliases - `yadm config local.class work`
test -f "$XDG_CONFIG_HOME/shell/alias.work.sh" && source "$XDG_CONFIG_HOME/shell/alias.work.sh"
