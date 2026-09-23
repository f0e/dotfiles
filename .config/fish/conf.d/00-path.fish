# login fish rebuilds PATH from /etc/paths (like macOS path_helper)
# so restore the PATH we want that zsh built (passed in by ~/.config/zsh/.zshrc)
if set -q ZSH_PATH
    set -gx PATH (string split : -- $ZSH_PATH)
    set -e ZSH_PATH
end
