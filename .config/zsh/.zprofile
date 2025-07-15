# xdg base directory specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# tell zsh where to find its configuration files
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# use cursor as default editor
export EDITOR="cursor --wait"

# bat manpager
export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

# brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# disable et telemetry
export ET_NO_TELEMETRY=true

# vcpkg
export VCPKG_ROOT="$HOME/vcpkg"

# path
export PATH=$VCPKG_ROOT:$PATH                    # vcpkg
export PATH="$HOME/.local/bin:$PATH"             # uv
export PATH="/opt/homebrew/opt/cython/bin:$PATH" # cython
export PATH=$(brew --prefix llvm)/bin:$PATH      # prioritise brew llvm over mac clang stuff
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"  # postgres tools like psql

# misc
export LESS='-R --mouse' # https://github.com/dandavison/delta/issues/630#issuecomment-2003149860

# orbstack
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
