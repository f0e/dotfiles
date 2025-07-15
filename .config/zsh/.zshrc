#!/usr/bin/env zsh

# if not running interactively, don't do anything
[[ $- != *i* ]] && return

PROFILE=0

((PROFILE)) && zmodload zsh/zprof

# ────────────────────────────── scripts ──────────────────────────────

# IMPORTANT: $PATH in sourced scripts is the path to the script itself.
# So we assign the parent .zshrc PATH to MODIFIED_PATH and use that in sourced scripts.
# We do this by re-assigning PATH in the sourced script to MODIFIED_PATH.
# Then at the end of the sourced script we re-export the updated MODIFIED_PATH.
# Later on you'll see us prefix this .zshrc PATH with MODIFIED_PATH.
export MODIFIED_PATH="$PATH"

function load_script {
  local path=$1
  if test -f $path; then
    source $path
  else
    print -u2 -- "ERROR: script '$path' not found"
  fi
}

# anything that modifies path or is required by stuff in zshrc, call it here.
# otherwise, defer (see below)
load_script "$XDG_CONFIG_HOME/zsh/scripts/tools.zsh"

# cursor fix (https://forum.cursor.com/t/cursor-agent-terminal-doesn-t-work-well-with-powerlevel10k-oh-my-zsh/96808/12)
if [[ -n $CURSOR_TRACE_ID ]]; then
  PROMPT_EOL_MARK=""
  load_script "$XDG_CONFIG_HOME/zsh/integrations/iterm2_shell_integration.zsh"
  precmd() { print -Pn "\e]133;D;%?\a"; }
  preexec() { print -Pn "\e]133;C;\a"; }
fi

export PATH="$MODIFIED_PATH:$PATH"
typeset -U path # dedupe

# ────────────────────────────── p10k instant prompt ──────────────────────────────

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ────────────────────────────── opts ──────────────────────────────

setopt auto_menu menu_complete # show menu on first tab hit after partial completion
setopt autocd # type a dir to cd (nice zoxide fallback)
setopt auto_param_slash # when a dir is completed, add a / instead of a trailing space
setopt no_case_glob no_case_match # make cmp case insensitive
setopt globdots # include dotfiles
setopt extended_glob # match ~ # ^
setopt interactive_comments # allow comments in shell
unsetopt prompt_sp # don't autoclean blanklines

# https://stackoverflow.com/a/42679697
unsetopt nomatch

bindkey '\e[H' beginning-of-line # fn + left to start of line
bindkey '\e[F' end-of-line # fn + right to end of line

# WORDCHARS="" # use native word separation behaviour
# use bash-like word skipping
autoload -U select-word-style
select-word-style bash

# ────────────────────────────── history opts ──────────────────────────────

HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE="$XDG_CACHE_HOME/zsh_history" # move histfile to cache
HISTCONTROL=ignoreboth # consecutive duplicates & commands starting with space are not saved

setopt append_history # on exit, history appends rather than overwrites
setopt inc_append_history # history is appended as soon as cmds executed
setopt share_history # history shared across sessions

# ────────────────────────────── plugins (antidote) ──────────────────────────────

# Lazy-load antidote and generate the static load file only when needed
zsh_plugins=$ZDOTDIR/.zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  (
    source "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh"
    antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
  )
fi

export FORGIT_NO_ALIASES=1 # https://github.com/wfxr/forgit#shell-aliases i dont like them

# load plugins
source ${zsh_plugins}.zsh

PATH="$PATH:$FORGIT_INSTALL_DIR/bin" # https://github.com/wfxr/forgit#git-integration

# zsh-history-substring-search configuration
bindkey '^[[A' history-substring-search-up # or '\eOA'
bindkey '^[[B' history-substring-search-down # or '\eOB'
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# ────────────────────────────── other scripts ──────────────────────────────

load_script "$XDG_CONFIG_HOME/zsh/scripts/bindings-Integralist.zsh"
load_script "$XDG_CONFIG_HOME/zsh/scripts/functions.zsh"
load_script "$XDG_CONFIG_HOME/shell/alias.sh"

# ────────────────────────────── completion styles ──────────────────────────────

# set up LS_COLORS
export LS_COLORS="$(vivid generate catppuccin-mocha)"

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# fzf-tab preview configuration
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# show file contents for other commands
zstyle ':fzf-tab:complete:(cat|less|more|vim|nvim|nano):*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || cat $realpath'
# general file preview for ls command and others
zstyle ':fzf-tab:complete:ls:*' fzf-preview '[[ -f $realpath ]] && bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || [[ -d $realpath ]] && eza -1 --color=always $realpath'
# enable preview for all commands by default
zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [[ -f $realpath ]]; then bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || cat $realpath; elif [[ -d $realpath ]]; then eza -1 --color=always $realpath; fi'
# custom fzf flags to start with preview hidden and toggle with space
zstyle ':fzf-tab:*' fzf-flags --preview-window=right:50%:wrap:hidden --bind 'space:toggle-preview'
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# ────────────────────────────── activations ──────────────────────────────

_evalcache fzf --zsh
_evalcache mise activate zsh
_evalcache zoxide init zsh
_evalcache atuin init zsh --disable-up-arrow

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# ────────────────────────────── header ──────────────────────────────

COLOUR_BG_DARK="#121211"
COLOUR_FG_LIGHT="#d5c4a1"
COLOUR_BG_LIGHT="#21201e"
COLOUR_FG_DARK="#ab9d82"
COLOUR_FG_DIM="#8c816b"

show_uptime_header() {
  local shell_path uptime_str uptime_part days="" hours="" minutes="" readable_uptime=""
  shell_path=${SHELL:-$0}
  uptime_str=$(uptime)

  # Extract part after "up " and before "user"
  uptime_part=${uptime_str#*up }
  uptime_part=${uptime_part%% user*}

  # Check for "X day(s)"
  if [[ $uptime_part =~ ([0-9]+)\ day ]]; then
    days=${match[1]##0}
    [[ -z $days ]] && days=0
    days="$days day"
    [[ $days != "1 day" ]] && days+="s"
  fi

  # Check for HH:MM format
  if [[ $uptime_part =~ ([0-9]+):([0-9]+) ]]; then
    hours=${match[1]##0}
    minutes=${match[2]##0}
    [[ -z $hours ]] && hours=0
    [[ -z $minutes ]] && minutes=0

    [[ $hours -gt 0 ]] && hours="$hours hour$([[ $hours -eq 1 ]] || echo s)"
    [[ $minutes -gt 0 ]] && minutes="$minutes minute$([[ $minutes -eq 1 ]] || echo s)"
  elif [[ $uptime_part =~ ([0-9]+)\ min ]]; then
    minutes=${match[1]##0}
    [[ -z $minutes ]] && minutes=0
    minutes="$minutes minute$([[ $minutes -eq 1 ]] || echo s)"
  fi

  # Build readable uptime string
  [[ -n $days ]] && readable_uptime+="$days"
  [[ -n $hours ]] && readable_uptime+="${readable_uptime:+, }$hours"
  [[ -n $minutes ]] && readable_uptime+="${readable_uptime:+, }$minutes"

  print -P "%K{$COLOUR_BG_DARK}%F{$COLOUR_FG_DIM} ${shell_path} %K{$COLOUR_BG_LIGHT}%F{$COLOUR_FG_DARK} up ${readable_uptime} %k%f"
}

# show_uptime_header

# ────────────────────────────── p10k prompt ──────────────────────────────

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# ────────────────────────────────────────────────────────

((PROFILE)) && zprof
