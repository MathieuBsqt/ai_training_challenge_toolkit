#!/bin/bash
set -eu
set -o pipefail

if [ $# -ne 0 ]; then
    echo "You should not pass any argument"
    exit 1
fi

jq -n --slurpfile jobs <( ovhai job list  -o json )  --slurpfile tokens <( ovhai token list  -o json ) -r 'include "lib"; list_running_ids($jobs;$tokens)' | xargs -n 1 -L 1 -I {} ovhai job exec -- {} bash -c 'echo {},$(ps -fu ovh | grep jupyter | grep -v grep | wc -l)' |
jq -R 'split(",") | {id: .[0], nb: (.[1]|tonumber)} | ( .workspace_init_status = (if .nb > 0 then "success" else "ongoing" end))  ' | jq -s 'group_by(.workspace_init_status) | map({workspace_init_status: .[0].workspace_init_status, nb: length})'