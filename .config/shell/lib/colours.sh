#!/bin/sh

if [ -t 1 ] && [ -z "${NO_COLOR-}" ]; then
  esc=$(printf '\033')
  red="$esc[31m"
  blue="$esc[34m"
  grey="$esc[90m"
  bold="$esc[1m"
  reset="$esc[0m"
  unset esc
else
  red='' blue='' grey='' bold='' reset=''
fi
