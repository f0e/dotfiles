#!/bin/sh

brewfile=${HOMEBREW_BUNDLE_FILE_GLOBAL:-${XDG_CONFIG_HOME:-$HOME/.config}/homebrew/Brewfile} # same file as `brew bundle -g`
[ -f "$brewfile" ] || exit 0

. "${XDG_CONFIG_HOME:-$HOME/.config}/shell/lib/colours.sh"
tag="$red[tools]$reset"

# brew's prefix, even if `brew shellenv` hasn't run
brew_bin=$(command -v brew)
brew_prefix=${HOMEBREW_PREFIX:-${brew_bin%/bin/brew}}

if [ -z "$brew_prefix" ]; then
  printf '%s brew not found. install Homebrew first: https://brew.sh\n\n' "$tag"
  exit 0
fi

# `brew "x"` / `cask "tap/name/x", ...` lines -> "brew x" / "cask tap/name/x"
missing=""
while read -r kind name; do
  short=${name##*/} # installed under the bare name, without the tap prefix
  case $kind in
  brew) [ -e "$brew_prefix/opt/$short" ] || missing="$missing $name" ;;
  cask) [ -d "$brew_prefix/Caskroom/$short" ] || missing="$missing $name" ;;
  esac
done <<EOF
$(sed -nE "s/^[[:space:]]*(brew|cask)[[:space:]]+[\"']([^\"']+)[\"'].*/\1 \2/p" "$brewfile")
EOF

# stay quiet when nothing is missing
[ -z "$missing" ] && exit 0

printf '%s missing:%s\n' "$tag" "$missing"
printf '%s install with: %sbrew bundle -g%s\n\n' "$tag" "$bold" "$reset"
