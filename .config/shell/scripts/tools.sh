#!/bin/sh

missing_tools() {
  case $(uname -s) in
  Darwin) missing_brew ;;
  MINGW* | MSYS*) missing_scoop ;;
  esac
}

missing_brew() {
  brewfile=${HOMEBREW_BUNDLE_FILE_GLOBAL:-${XDG_CONFIG_HOME:-$HOME/.config}/homebrew/Brewfile} # same file as `brew bundle -g`
  [ -f "$brewfile" ] || return

  tag="$red[tools]$reset"

  brew_prefix=${HOMEBREW_PREFIX:-$(command -v brew)}
  brew_prefix=${brew_prefix%/bin/brew}

  if [ -z "$brew_prefix" ]; then
    printf '%s brew not found. install Homebrew first: https://brew.sh\n\n' "$tag"
    return
  fi

  # `brew "x"` / `cask "tap/name/x", ...` lines -> kind=brew/cask, name=x / tap/name/x
  # (parsed with builtins rather than sed, to avoid spawning a process)
  missing=""
  while read -r kind rest; do
    case $kind in brew | cask) ;; *) continue ;; esac

    name=${rest#[\"\']}
    name=${name%%[\"\']*}
    short=${name##*/} # installed under the bare name, without the tap prefix

    case $kind in
    brew) [ -e "$brew_prefix/opt/$short" ] || missing="$missing $name" ;;
    cask) [ -d "$brew_prefix/Caskroom/$short" ] || missing="$missing $name" ;;
    esac
  done <"$brewfile"

  [ -z "$missing" ] && return

  printf '%s missing:%s\n' "$tag" "$missing"
  printf '%s install with: %sbrew bundle -g%s\n\n' "$tag" "$bold" "$reset"
}

missing_scoop() {
  scoopfile=${XDG_CONFIG_HOME:-$HOME/.config}/scoop/scoopfile.json
  [ -f "$scoopfile" ] || return 0

  tag="$red[tools]$reset"

  if ! command -v scoop >/dev/null; then
    printf '%s scoop not found. install scoop first: https://scoop.sh\n\n' "$tag"
    return
  fi

  # one `{ "Name": "x", "Source": "bucket" }` per line, skipping buckets (their source is a url)
  missing=""
  while read -r line; do
    case $line in *'"Name": "'*) ;; *) continue ;; esac
    case $line in *'"Source": "http'*) continue ;; esac

    name=${line#*'"Name": "'}
    name=${name%%\"*}
    [ -d "${SCOOP:-$HOME/scoop}/apps/$name" ] || missing="$missing $name"
  done <"$scoopfile"

  [ -z "$missing" ] && return 0

  printf '%s missing:%s\n' "$tag" "$missing"
  printf '%s install with: %sscoop import ~/.config/scoop/scoopfile.json%s\n\n' "$tag" "$bold" "$reset"
}
