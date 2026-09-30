if status is-interactive
    sh $XDG_CONFIG_HOME/shell/scripts/startup.sh (command -s fish)
    set -gx HEADER_PARENT_SHELL (command -s fish) # tells child shells they are nested, and in what
end
