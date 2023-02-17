#!/bin/bash
set -eu
set -o pipefail

source ./lib.sh

if [ $# -ne 0 ]; then
    echo "You should not pass any argument"
    exit 1
fi

jq -n --argfile jobs <( ovhai job list  -o json )  --argfile tokens <( ovhai token list  -o json )  --argfile teams $TEAMS_JSON 'include "lib"; export_list($jobs;$tokens;$teams)'