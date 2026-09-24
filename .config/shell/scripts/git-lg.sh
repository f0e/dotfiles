#!/bin/sh

# git log graph in fzf with a diff preview on the right

format='%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(green)(%cr)%C(reset)'

# if piped return plain log without fzf
if [ ! -t 1 ]; then
  exec git log --graph --pretty=format:"$format" --abbrev-commit "$@"
fi

hash='h=$(echo {} | grep -oE "[0-9a-f]{7,}" | head -1); [ -n "$h" ]'

git log --graph --color=always --pretty=format:"$format" --abbrev-commit "$@" |
  fzf --ansi --no-sort --reverse --preview-window=right:60% \
    --preview "$hash && git show --color=always \$h | delta --width=\$FZF_PREVIEW_COLUMNS" \
    --bind "enter:execute($hash && git show \$h)"
