#!/bin/sh

# path
export PATH="$VCPKG_ROOT:$PATH"                     # vcpkg
export PATH="$HOME/.local/bin:$PATH"                # uv
export PATH="$HOMEBREW_PREFIX/opt/cython/bin:$PATH" # cython
export PATH="$HOMEBREW_PREFIX/opt/llvm/bin:$PATH"   # prioritise brew llvm over mac clang stuff
export PATH="$HOMEBREW_PREFIX/opt/libpq/bin:$PATH"  # postgres tools like psql

# colours for ls/eza/completion by file type
command -v vivid >/dev/null 2>&1 && export LS_COLORS="$(vivid generate gruvbox-dark)" # vivid themes | fzf --preview 'vivid preview {}'
