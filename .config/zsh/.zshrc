#!/usr/bin/env zsh

# read by interactive shells only, after .zshenv/.zprofile (see $ZDOTDIR/.zshenv for what goes where).
# env vars and PATH belong in those files, not here - this is for options, plugins, prompt, keybinds.

ZSH_PROFILE=0

((ZSH_PROFILE)) && zmodload zsh/zprof

# ────────────────────────────── scripts ──────────────────────────────

function load_script {
  local file=$1
  if [[ -f $file ]]; then
    source $file
  else
    print -u2 -P "%F{red}[zshrc]%f script not found: $file"
  fi
}

# deduplicate paths
typeset -U path fpath

# ────────────────────────────── fish handoff ──────────────────────────────

# handoff to fish shell unless NO_FISH=1, or the parent is already fish (so `zsh` inside fish works)
# also skipped for `zsh -ic 'cmd'` (how IDEs read your env), or exec would drop the command
if [[ -z $NO_FISH && -z $ZSH_EXECUTION_STRING ]] && (( $+commands[fish] )) \
  && [[ ${$(ps -o comm= -p $PPID):t} != (-|)fish ]]; then
  if [[ -o login ]]; then
    # login fish puts system dirs first in PATH, so pass ours for fish/conf.d/00-path.fish to restore
    ZSH_PATH=$PATH exec fish --login
  else
    exec fish
  fi
fi

# ────────────────────────────── opts ──────────────────────────────

setopt autocd # type a dir to cd
setopt no_case_glob # case insensitive globbing (completion is handled by the matcher-list zstyle below)
setopt globdots # include dotfiles
setopt extended_glob # match ~ # ^
setopt interactive_comments # allow comments in shell

# don't error on unmatched globs, so e.g. `curl url?a=1` works unquoted
# https://stackoverflow.com/a/42679697
unsetopt nomatch

# ────────────────────────────── keybindings ──────────────────────────────

# emacs mode explicitly - zsh silently switches to vi mode if $EDITOR contains "vi"
bindkey -e

bindkey '\e[H' beginning-of-line # fn + left to start of line
bindkey '\e[F' end-of-line # fn + right to end of line

# bash word selection style
autoload -U select-word-style
select-word-style bash

# ────────────────────────────── history opts ──────────────────────────────

HISTFILE="$XDG_STATE_HOME/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p ${HISTFILE:h}
HISTSIZE=1000000
SAVEHIST=1000000

setopt share_history # history shared across sessions (also appends as soon as cmds are executed)
setopt extended_history # save a timestamp and duration with each command
setopt hist_ignore_dups # don't save a command if it's the same as the previous one
setopt hist_ignore_space # don't save commands starting with a space
setopt hist_reduce_blanks # strip extra whitespace from saved commands

# ────────────────────────────── plugins (antidote) ──────────────────────────────

# regenerate the static plugin file only when .zsh_plugins.txt changes (faster than loading antidote every time)
zsh_plugins=$ZDOTDIR/.zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  if [[ ! -f "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh" ]]; then
    print -u2 -P "%F{red}[zshrc]%f antidote not found"
  else
    (
      source "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh"
      antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.tmp && mv ${zsh_plugins}.tmp ${zsh_plugins}.zsh
    )
  fi
fi

# load plugins
source ${zsh_plugins}.zsh

# https://github.com/wfxr/forgit#git-integration
path+=("$FORGIT_INSTALL_DIR/bin")

# up/down arrows search history for commands containing what's typed so far
bindkey '^[[A' history-substring-search-up # or '\eOA'
bindkey '^[[B' history-substring-search-down # or '\eOB'
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1 # skip duplicate matches

# ────────────────────────────── other scripts ──────────────────────────────

load_script "$XDG_CONFIG_HOME/zsh/scripts/bindings-Integralist.zsh"

load_script "$XDG_CONFIG_HOME/shell/alias.sh"

# ────────────────────────────── completion styles ──────────────────────────────

# case insensitive completion (e.g. `cd desk<tab>` -> Desktop)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# cache slow completions, in XDG cache rather than $ZDOTDIR
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# colour completion candidates using LS_COLORS (set in ~/.config/shell/profile.sh)
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# fzf-tab preview: file contents with bat, directory contents with eza
zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [[ -f $realpath ]]; then bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || cat $realpath; elif [[ -d $realpath ]]; then eza -1 --color=always $realpath; fi'
# custom fzf flags to start with preview hidden and toggle with space
zstyle ':fzf-tab:*' fzf-flags --preview-window=right:50%:wrap:hidden --bind 'space:toggle-preview'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# ────────────────────────────── activations ──────────────────────────────

(( $+commands[fzf] )) && eval "$(fzf --zsh)"
(( $+commands[mise] )) && eval "$(mise activate zsh)" 
(( $+commands[zoxide] )) && eval "$(zoxide init zsh --cmd cd)"
(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"

# ────────────────────────────── startup ──────────────────────────────

sh "$XDG_CONFIG_HOME/shell/scripts/startup.sh" "$SHELL"

# ────────────────────────────── starship prompt ──────────────────────────────

eval "$(starship init zsh)"

# ────────────────────────────────────────────────────────

((ZSH_PROFILE)) && zprof
