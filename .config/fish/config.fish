# env (PATH, EDITOR, LS_COLORS, brew, etc) is inherited from zsh since it launches fish

# install fisher plugins outside of here
set -g fisher_path ~/.local/share/fisher
set fish_function_path $fish_function_path[1] $fisher_path/functions $fish_function_path[2..]
set fish_complete_path $fish_complete_path[1] $fisher_path/completions $fish_complete_path[2..]
for file in $fisher_path/conf.d/*.fish
    source $file
end

if status is-interactive
    function fish_greeting
        sh $XDG_CONFIG_HOME/shell/scripts/startup.sh (command -s fish)
    end

    source $XDG_CONFIG_HOME/shell/alias.sh

    # https://github.com/wfxr/forgit#git-integration
    set -q FORGIT_INSTALL_DIR; and fish_add_path -g --append $FORGIT_INSTALL_DIR/bin

    # (options here mirror ~/.config/zsh/.zshrc "completion styles")
    set -g fifc_custom_fzf_opts --preview-window=right:50%:wrap:hidden --bind space:toggle-preview
    set -g fifc_bat_opts --style=numbers --line-range=:500
    set -g fifc_eza_opts -1

    # ghostty shell integration isn't auto-injected since fish is launched via zsh
    if set -q GHOSTTY_RESOURCES_DIR
        source $GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish
    end

    # init tools
    type -q fzf; and fzf --fish | source
    type -q mise; and mise activate fish | source
    type -q zoxide; and zoxide init fish --cmd cd | source
    type -q atuin; and atuin init fish --disable-up-arrow | source

    # prompt
    starship init fish | source
end
