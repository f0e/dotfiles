#!/bin/sh

# shares ~/.claude-personal's setup into other claude config dirs (same split as cpm):
# dirs are symlinked, settings.json/CLAUDE.md are copied since claude saves them by
# write-then-rename, which would replace a symlink with a real file
# usage: claude-sync.sh [--push] <config dir>...
#   --push: replace real dirs with links and overwrite the copies (originals go to <dir>/backups)

. "$XDG_CONFIG_HOME/shell/lib/colours.sh"

primary="$HOME/.claude-personal"
linked='projects plugins hooks commands agents'
copied='settings.json CLAUDE.md'

push=
[ "${1-}" = --push ] && { push=1; shift; }

for dir in "$@"; do
  backup="$dir/backups/claude-sync-$(date +%Y%m%d-%H%M%S)"
  stash() { mkdir -p "$backup" && mv "$1" "$backup/"; }

  for name in $linked; do
    src="$primary/$name" dst="$dir/$name"
    [ "$(readlink "$dst")" = "$src" ] && continue
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      if [ -z "$push" ]; then
        printf '%sclaude-sync:%s %s is not linked, rerun with --push to replace it\n' "$red" "$reset" "$dst" >&2
        continue
      fi
      stash "$dst"
    fi
    mkdir -p "$src" # so the link isn't dangling for dirs primary hasn't made yet
    ln -s "$src" "$dst"
  done

  for name in $copied; do
    src="$primary/$name" dst="$dir/$name"
    [ -f "$src" ] || continue
    cmp -s "$src" "$dst" && continue
    if [ -e "$dst" ] && [ -z "$push" ]; then
      printf '%sclaude-sync:%s %s differs from primary (diff "%s" "%s"), rerun with --push to overwrite\n' \
        "$red" "$reset" "$dst" "$src" "$dst" >&2
      continue
    fi
    [ -e "$dst" ] && stash "$dst"
    cp "$src" "$dst"
  done
done
