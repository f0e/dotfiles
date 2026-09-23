# read by login shells only (every new terminal tab on macOS), after .zshenv.
# PATH setup goes here (see the note in ~/.zshenv), plus anything that runs a command.
# fish inherits all of this, since zsh is the login shell and execs into fish from .zshrc.

eval "$(/opt/homebrew/bin/brew shellenv zsh)"

source "$XDG_CONFIG_HOME/shell/profile.sh"

source ~/.orbstack/shell/init.zsh 2>/dev/null || :
