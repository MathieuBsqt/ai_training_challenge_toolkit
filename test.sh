#!/bin/bash
set -eu
set -o pipefail

if [ $# -ne 0 ]; then
    echo "You should not pass any argument"
    exit 1
fi

jq -n --slurpfile jobs <( ovhai job list  -o json )  --slurpfile tokens <( ovhai token list  -o json ) 'include "lib"; test($jobs;$tokens)'