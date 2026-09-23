#!/bin/sh

shell_path=${1:-$SHELL}

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
  exit 0
fi

days=$((secs / 86400))
hours=$((secs % 86400 / 3600))
minutes=$((secs % 3600 / 60))

# "1 day" / "2 days", skipping zero units
unit() {
  [ "$1" -eq 0 ] && return
  [ "$1" -eq 1 ] && printf '%s %s' "$1" "$2" || printf '%s %ss' "$1" "$2"
}

# e.g. "2 days, 3 hours, 1 minute"
uptime=""
for part in "$(unit $days day)" "$(unit $hours hour)" "$(unit $minutes minute)"; do
  [ -n "$part" ] && uptime="${uptime:+$uptime, }$part"
done
[ -z "$uptime" ] && uptime="less than a minute"

. "${XDG_CONFIG_HOME:-$HOME/.config}/shell/lib/colours.sh"

printf '%s%s %s %s%s up %s %s\n\n' "$header_bg" "$blue" "$shell_path" "$header_bg_dim" "$grey" "$uptime" "$reset"
