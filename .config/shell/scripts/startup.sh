#!/bin/sh

config=${XDG_CONFIG_HOME:-$HOME/.config}

# source rather than run with `sh`, saves a tiny bit of time
. "$config/shell/lib/colours.sh"
. "$config/shell/scripts/uptime-header.sh"
. "$config/shell/scripts/tools.sh"

uptime_header "$1"
missing_tools
