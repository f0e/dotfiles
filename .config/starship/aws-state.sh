#!/bin/sh
# Prints ok|soon|expired for the current aws-vault session (exit 1 if none).
[ -n "$AWS_VAULT" ] || exit 1
exp="${AWS_CREDENTIAL_EXPIRATION:-$AWS_SESSION_EXPIRATION}"
[ -n "$exp" ] || { echo ok; exit 0; }
exp_s=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "${exp%%Z*}" +%s 2>/dev/null) || { echo ok; exit 0; }
left=$((exp_s - $(date +%s)))
if [ "$left" -le 0 ]; then echo expired
elif [ "$left" -le 900 ]; then echo soon
else echo ok; fi
