# shellcheck disable=SC1036,SC1072,SC1073,SC1009

# # if not running interactively, don't do anything
# [[ $- != *i* ]] && return

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
load_script "$XDG_CONFIG_HOME/zsh/tools.zsh"

export PATH="$MODIFIED_PATH:$PATH"
typeset -U path # dedupe

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

WORDCHARS="" # use native word separation behaviour

# ────────────────────────────── history opts ──────────────────────────────

HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE="$XDG_CACHE_HOME/zsh_history" # move histfile to cache
HISTCONTROL=ignoreboth # consecutive duplicates & commands starting with space are not saved

setopt append_history # on exit, history appends rather than overwrites
setopt inc_append_history # history is appended as soon as cmds executed
setopt share_history # history shared across sessions

# ────────────────────────────── prompt ──────────────────────────────

eval "$(starship init zsh)"

# ────────────────────────────── zinit ──────────────────────────────

source "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/zinit/zinit.zsh"

# completions
run_compinit() {
  autoload -Uz compinit
  local zcompdump=${ZDOTDIR:-$HOME}/.zcompdump
  if [[ ! -f $zcompdump || -n $zcompdump(#qN.md+1) ]]; then
    compinit -d $zcompdump
  else
    compinit -C -d $zcompdump
  fi
}

export FORGIT_NO_ALIASES=1 # https://github.com/wfxr/forgit#shell-aliases i dont like them

zinit wait lucid for \
  `# completions` \
  atload'run_compinit' \
    zdharma-continuum/null \
  \
  `# plugins` \
    zsh-users/zsh-completions \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-history-substring-search \
    Aloxaf/fzf-tab \
    blimmer/zsh-aws-vault \
    mroth/evalcache \
  atload'PATH="$PATH:$FORGIT_INSTALL_DIR/bin"' \
    wfxr/forgit \
  \
  `# deferred scripts` \
  atload"load_script '$XDG_CONFIG_HOME/zsh/bindings-Integralist.zsh'" \
  atload"load_script '$XDG_CONFIG_HOME/zsh/functions.zsh'" \
  atload"load_script '$XDG_CONFIG_HOME/shell/alias.sh'" \
    zdharma-continuum/null \
  \
  `# tool activations` \
  atload'_evalcache fzf --zsh' \
  atload'_evalcache mise activate zsh' \
  atload'_evalcache zoxide init zsh' \
  atload'_evalcache atuin init zsh --disable-up-arrow' \
    zdharma-continuum/null

# ────────────────────────────── completion styles ──────────────────────────────

cmp_opts() {
  zstyle ':completion:*' menu select

  # disable sort when completing `git checkout`
  zstyle ':completion:*:git-checkout:*' sort false
  # set descriptions format to enable group support
  # NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
  zstyle ':completion:*:descriptions' format '[%d]'
  # set list-colors to enable filename colorizing
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

  # preview directory's content with eza when completing cd
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
  # custom fzf flags
  # To make fzf-tab follow FZF_DEFAULT_OPTS.
  # NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
  zstyle ':fzf-tab:*' use-fzf-default-opts yes
  # switch group using `<` and `>`
  zstyle ':fzf-tab:*' switch-group '<' '>'
}

zinit ice wait'2' lucid atload'cmp_opts'
zinit light zdharma-continuum/null

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

  echo "%K{$COLOUR_BG_DARK}%F{$COLOUR_FG_DIM} ${shell_path} %K{$COLOUR_BG_LIGHT}%F{$COLOUR_FG_DARK} up ${readable_uptime} %k%f"
}

# Precalculate the header
__uptime_header=$(show_uptime_header)

# Register a precmd hook to print it once
__show_header_once=true
autoload -Uz add-zsh-hook
add-zsh-hook precmd show_uptime_header_once

show_uptime_header_once() {
  if [[ $__show_header_once == true ]]; then
    print -P "$__uptime_header"
    __show_header_once=false
  fi
}

# ────────────────────────────────────────────────────────

((PROFILE)) && zprof
