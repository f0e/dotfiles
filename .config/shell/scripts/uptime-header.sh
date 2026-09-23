#!/bin/sh

# appends "1 day" / "2 days" to $uptime, skipping zero units
append_unit() {
  [ "$1" -eq 0 ] && return
  [ "$1" -eq 1 ] && part="$1 $2" || part="$1 ${2}s"
  uptime="${uptime:+$uptime, }$part"
}

# prints the shell path and how long the machine has been up, e.g. "up 2 days, 3 hours, 1 minute"
uptime_header() {
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
    return
  fi

  uptime=""
  append_unit $((secs / 86400)) day
  append_unit $((secs % 86400 / 3600)) hour
  append_unit $((secs % 3600 / 60)) minute
  [ -z "$uptime" ] && uptime="less than a minute"

  printf '%s%s %s %s%s up %s %s\n\n' "$header_bg" "$blue" "$shell_path" "$header_bg_dim" "$grey" "$uptime" "$reset"
}
