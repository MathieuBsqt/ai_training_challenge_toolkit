#!/bin/bash
set -eu
set -o pipefail

if [ $# -ne 0 ]; then
    echo "You should not pass any argument"
    exit 1
fi

jq -n --slurpfile jobs <( ovhai job list  -o json )  --slurpfile tokens <( ovhai token list  -o json )  --slurpfile teams teams.json 'include "lib"; export_list($jobs;$tokens;$teams)'