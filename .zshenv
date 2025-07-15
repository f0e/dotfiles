# this file is read by all zsh shells (login, non-login, interactive, non-interactive)

# xdg base directory specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# tell zsh where to find its configuration files
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
