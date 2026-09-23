#!/bin/sh

# rgb escape from a hex colour
# fg: hex_escape 38 "#b5be8b"
# bg: hex_escape 48 "#b5be8b"
hex_escape() {
  hex=${2#\#}
  r=${hex%????} g=${hex#??} g=${g%??} b=${hex#????}
  printf '\033[%s;2;%d;%d;%dm' "$1" "0x$r" "0x$g" "0x$b"
}

if [ -t 1 ] && [ -z "${NO_COLOR-}" ]; then
  esc=$(printf '\033')

  red="$esc[38;2;234;105;98m"   # #ea6962
  blue="$esc[38;2;181;190;139m" # sage #b5be8b (name kept for callers)
  grey="$esc[38;2;82;84;74m"    # muted olive #52544a, sits on the olive header backgrounds

  header_bg="$esc[48;2;22;24;20m"     # #161814
  header_bg_dim="$esc[48;2;16;16;13m" # #10100d, fainter for the uptime half

  bold="$esc[1m"
  reset="$esc[0m"

  unset esc
else
  red='' blue='' grey='' header_bg='' header_bg_dim='' bold='' reset=''
fi
