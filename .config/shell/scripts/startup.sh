#!/bin/sh

dir=${0%/*}
sh "$dir/uptime-header.sh" "$1"
sh "$dir/tools.sh"
