# filename starts with 00- so it runs before other conf.d files

source ~/.config/shell/env.sh

if status is-login
    /opt/homebrew/bin/brew shellenv fish | source

    source $XDG_CONFIG_HOME/shell/profile.sh

    test -f ~/.orbstack/shell/init2.fish; and source ~/.orbstack/shell/init2.fish

    # dedupe path
    set -l path
    for dir in $PATH
        contains -- $dir $path; or set -a path $dir
    end
    set -gx PATH $path
end
