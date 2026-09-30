# aws-vault helpers (fish port of the aliases from https://github.com/blimmer/zsh-aws-vault)

status is-interactive; or exit
type -q aws-vault; or exit

alias av='aws-vault'
alias avs='aws-vault server'
alias avl='aws-vault login'
alias avll='aws-vault login -s'
alias ave='aws-vault exec'

# open a fish subshell with a profile's creds (plain `aws-vault exec` would use $SHELL)
function avsh --description 'aws-vault exec <profile> into a fish subshell'
    aws-vault exec $argv -- fish
end

# refresh the current aws-vault session's creds in place
function avr --description 'reload creds for the current aws-vault profile'
    if not set -q AWS_VAULT; or test -z "$AWS_VAULT"
        echo "avr: not in an aws-vault session" >&2
        return 1
    end
    set -l creds (env AWS_VAULT= aws-vault export --format=export-env $AWS_VAULT); or return
    string join \n $creds | source
end

# load dev profile
function avd --description 'aws-vault exec $AWS_VAULT_DEV_PROFILE'
    if not set -q AWS_VAULT_DEV_PROFILE
        echo "avd: set your dev profile first: set -U AWS_VAULT_DEV_PROFILE <profile>" >&2
        return 1
    end
    if test (count $argv) -eq 0
        avsh $AWS_VAULT_DEV_PROFILE
    else
        aws-vault exec $AWS_VAULT_DEV_PROFILE -- $argv
    end
end
