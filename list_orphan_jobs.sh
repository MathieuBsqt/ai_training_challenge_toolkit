#!/bin/bash
set -eu
set -o pipefail

if [ $# -ne 0 ]; then
    echo "You should not pass any argument"
    exit 1
fi

jq -n --slurpfile jobs <( bkt -- ovhai job list  -o json )  --slurpfile tokens <( bkt -- ovhai token list  -o json ) 'include "lib"; list_orphan_jobs($jobs;$tokens)'

