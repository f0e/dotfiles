. "$HOME/.config/shell/env.sh"
. "$XDG_CONFIG_HOME/shell/profile.sh"

command -v starship >/dev/null && eval "$(starship init bash)"

. "$XDG_CONFIG_HOME/shell/alias.sh"
alias claude2='CLAUDE_CONFIG_DIR="$HOME/.claude2" command claude'

case $- in *i*)
  # stop git bash converting the path when sh resolves to scoop's windows shim
  MSYS2_ARG_CONV_EXCL='*' sh "$XDG_CONFIG_HOME/shell/scripts/startup.sh" "$BASH"
  export HEADER_PARENT_SHELL=$BASH
  ;;
esac
