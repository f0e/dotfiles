#!/bin/sh

# git restage <commit>...
# rebase back to the given commits, stopping at each one with its changes
# unstaged (on top of its parent) so it can be re-committed or split up.
# after committing, `git rebase --continue` moves on to the next one.

# rebase calls this script back as the sequence editor to rewrite the todo list
if [ "$1" = --todo ]; then
  todo=$2
  tmp=$todo.restage
  while IFS= read -r line; do
    echo "$line"
    case $line in
      pick\ *) ;;
      *) continue ;;
    esac
    set -- $line
    full=$(git rev-parse "$2")
    case " $RESTAGE_COMMITS " in
      *" $full "*)
        # -N keeps files added by the commit visible in `git diff`.
        # leaving the tree dirty makes rebase stop here
        # and print the original message to reuse when recommitting
        echo "exec git reset -q -N HEAD^ && git log -1 --format='%n--- restage: $2 unstaged, message was: ---%n%n%B' $full"
        ;;
    esac
  done <"$todo" >"$tmp"
  mv "$tmp" "$todo"
  exit
fi

[ $# -gt 0 ] || { echo "usage: git restage <commit>..." >&2; exit 1; }

commits=
for c in "$@"; do
  full=$(git rev-parse --verify --quiet "$c^{commit}") || { echo "restage: bad commit '$c'" >&2; exit 1; }
  git merge-base --is-ancestor "$full" HEAD || { echo "restage: $c is not in HEAD's history" >&2; exit 1; }
  commits="$commits $full"
done

# oldest given commit = last one to appear in HEAD's history
oldest=$(git rev-list HEAD | grep -F "$(printf '%s\n' $commits)" | tail -1)

if git rev-parse --verify --quiet "$oldest^" >/dev/null; then
  base="$oldest^"
else
  base=--root
fi

RESTAGE_COMMITS=$commits GIT_SEQUENCE_EDITOR="'$0' --todo" \
  exec git rebase -i --no-autosquash "$base"
