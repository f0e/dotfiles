#!/bin/sh

# appends "1 day" / "2 days" to $uptime, skipping zero units
append_unit() {
  [ "$1" -eq 0 ] && return
  [ "$1" -eq 1 ] && part="$1 $2" || part="$1 ${2}s"
  uptime="${uptime:+$uptime, }$part"
}

# recolours the header with a hue picked from the shell's name
# results are cached (~/.cache/shell/header-colours)
shell_colours() {
  [ -n "$reset" ] || return # colours disabled

  name=${1##*/}
  cache=${XDG_CACHE_HOME:-$HOME/.cache}/shell/header-colours/$name

  if [ ! -s "$cache" ]; then
    command -v pastel >/dev/null || return

    case $name in
    fish) hue=125 ;; # green
    zsh) hue=260 ;;  # blue
    *)
      set -- $(printf %s "$name" | cksum) # checksum of the name -> stable hue 0-359
      hue=$(($1 % 360))
      ;;
    esac

    mkdir -p "${cache%/*}"

    # same lightness/chroma as the default palette in colours.sh, only the hue changes
    pastel set hue "$hue" '#b5be8b' '#52544a' '#161814' '#10100d' | pastel format hex >"$cache"
  fi

  { read -r fg; read -r dim; read -r bg; read -r bg_dim; } <"$cache"
  blue=$(hex_escape 38 "$fg")
  grey=$(hex_escape 38 "$dim")
  header_bg=$(hex_escape 48 "$bg")
  header_bg_dim=$(hex_escape 48 "$bg_dim")
}

# prints the shell path and how long the machine has been up, e.g. "up 2 days, 3 hours, 1 minute"
uptime_header() {
  shell_path=${1:-$SHELL}
  shell_colours "$shell_path"

  # seconds since boot
  if boot=$(sysctl -n kern.boottime 2>/dev/null); then
    # macos: "{ sec = 1758590000, usec = 0 } Tue Sep 23 ..."
    boot=${boot#*sec = }
    boot=${boot%%,*}
    secs=$(($(date +%s) - boot))
  elif [ -r /proc/uptime ]; then
    # linux: "12345.67 54321.00"
    read -r secs _ </proc/uptime
    secs=${secs%%.*}
  else
    return
  fi

  uptime=""
  append_unit $((secs / 86400)) day
  append_unit $((secs % 86400 / 3600)) hour
  append_unit $((secs % 3600 / 60)) minute
  [ -z "$uptime" ] && uptime="less than a minute"

  printf '%s%s %s %s%s up %s %s\n\n' "$header_bg" "$blue" "$shell_path" "$header_bg_dim" "$grey" "$uptime" "$reset"
}
